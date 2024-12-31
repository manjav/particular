import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

import 'downloader/file_saver_none.dart'
    if (dart.library.io) 'downloader/file_saver_io.dart'
    if (dart.library.js_interop) 'downloader/file_saver_web.dart';

/// Browse files from the user's device.
///
/// This function uses the [FilePicker] library to allow the user to select
/// files. It returns a `Future` that resolves to a list of [PlatformFile]
/// objects. If the user cancels the selection, the function returns an empty
/// list.
///
/// Returns:
/// - A `Future<List<PlatformFile>>`: A list of [PlatformFile] objects
///   representing the selected files.
Future<List<PlatformFile>> browseFiles() async {
  // Use the FilePicker library to allow the user to select files.
  final pickResult = await FilePicker.platform.pickFiles(
    withData: true,
    type: FileType.any,
  );

  // If the user cancels the selection or no file is selected, return an empty
  // list. Otherwise, return the selected files.
  return pickResult?.files ?? [];
}

/// Browse and load an image from the user's device.
///
/// This function uses the [FilePicker] library to allow the user to select an
/// image file. If the user cancels the selection or no image is selected, the
/// function returns a `Future` that resolves to a tuple containing the empty
/// string and `null`. Otherwise, it reads the contents of the selected file,
/// decodes it from bytes and returns a `Future` that resolves to a tuple
/// containing the name of the selected file and the decoded image.
///
/// Returns:
/// - A `Future<(String, ui.Image?)>`: A tuple containing the name of the
///   selected file and the decoded image. If the user cancels the selection or
///   no image is selected, the tuple contains the empty string and `null`.
Future<(String, ui.Image?, Uint8List?)> browseImage() async {
  // Use the FilePicker library to allow the user to select an image file.
  final files = await browseFiles();

  if (files.isNotEmpty) {
    PlatformFile file = files.first;
    if (file.bytes != null) {
      var image = await loadUIImage(file.bytes!);
      return (file.name, image, file.bytes);
    }
  }

  return ("", null, null);
}

/// Browse and load configs from a file with specified extensions.
///
/// The function uses the [FilePicker] library to allow the user to select a file
/// with a specific set of extensions. If the user cancels the selection or no
/// file is selected, the function returns `null`. Otherwise, it reads the
/// contents of the selected file, decodes it from JSON and returns the decoded
/// map.
///
/// Parameters:
/// - [extensions]: A list of file extensions supported by the config file.
///
/// Returns:
/// - A `Future<dynamic>`: A map of configuration data, decoded
///   from JSON, or `null` if no file was selected.
Future<dynamic> browseConfigs(List<String> extensions) async {
  // Use the FilePicker library to allow the user to select a config file.
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    withData: true, // Request file contents.
    type: FileType.custom, // Allow any type of file.
    allowedExtensions:
        extensions, // Only allow files with specified extensions.
  );

  // If no file was selected, return null.
  if (result == null) return null;

  // Get the first selected file.
  PlatformFile file = result.files.first;

  // Decode the JSON contents of the file.
  String json = String.fromCharCodes(file.bytes!);
  return jsonDecode(json);
}

/// Browse and load configs and textures from a zip file.
///
/// The function uses the [FilePicker] library to allow the user to select a zip
/// file. If the user cancels the selection or no file is selected, the function
/// returns an empty map. Otherwise, it extracts the contents of the selected zip
/// file to disk, and returns a map of the extracted files.
///
/// Returns:
/// - A `Map<String, dynamic>`: A map of extracted files from the zip
Future<Map<String, dynamic>> browseConfigsWithTexture() async {
  // Use the FilePicker library to allow the user to select a config file.
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    withData: true, // Request file contents.
    type: FileType.custom, // Allow any type of file.
    allowedExtensions: ["zip"], // Only allow files with specified extensions.
  );

  // If no file was selected, return null.
  if (result == null) return {};

  // Decode the Zip file
  final archive = ZipDecoder().decodeBytes(result.files.first.bytes!);

  // Extract the contents of the Zip archive to disk.
  final files = <String, dynamic>{};
  for (final file in archive) {
    if (file.name.endsWith(".json")) {
      files[file.name] = jsonDecode(String.fromCharCodes(file.content));
    } else {
      var image = await loadUIImage(file.content);
      files[file.name] = (image, file.content);
    }
  }
  return files;
}

/// Save the provided configs to a file.
///
/// If the app is running on a non-web platform, the function uses the
/// [FilePicker.saveFile] method to open a file picker dialog for the user to
/// select a filename. The configs are encoded to JSON and saved to the
/// selected file with the `.json` extension.
///
/// Parameters:
/// - [configs]: The configs to save.
/// - [filename]: The name of the file to save the configs to. If not
///   provided, the filename will be "configs".
///
/// Returns:
/// - A `Future<void>`: A future that completes when the configs have been
///   saved to a file.
Future<void> saveConfigs({
  required dynamic configs,
  String? filename,
}) async {
  final json = jsonEncode(configs);
  debugPrint(json);
  await FileSaver.saveFile(
    bytes: utf8.encode(json),
    title: "Save Particle Configs",
    filename: "${filename ?? "configs"}.json",
  );
}

/// Saves the provided [configs] and [textures] to a zipped file.
///
/// If the app is running on a non-web platform, it uses the [FilePicker.saveFile]
/// method to open a file picker dialog for the user to select a filename.
///
/// The [configs] and [textures] are encoded into a zip file and saved to the
/// selected file with the `.zip` extension.
///
/// Parameters:
///   - [configs]: The configs to save.
///   - [textures]: The textures to save.
///   - [filename]: The name of the file to save the configs to. If not
///     provided, the filename will be "configs".
///
/// Returns:
///   A `Future<void>`: A future that completes when the configs and textures
///   have been saved to a file.
Future<void> saveConfigsWithTextures({
  required dynamic configs,
  required Map<String, Uint8List> textures,
  String? filename,
}) async {
  // Create ZipEncoder and AichiveFile instances.
  final encoder = ZipEncoder();
  final archive = Archive();

  // Add the configs.json to the archive.
  // Convert the configs to JSON and encode it into bytes.
  final json = jsonEncode(configs);
  final jbytes = utf8.encode(json);

  // Create a new ArchiveFile instance with the name 'configs.json' and the
  // encoded JSON bytes as the file contents.
  final archiveFile = ArchiveFile('configs.json', jbytes.length, jbytes);
  archive.addFile(archiveFile);

  // Add the textures into the archive.
  for (var entry in textures.entries) {
    archive.addFile(ArchiveFile(entry.key, entry.value.length, entry.value));
  }

  // Create an OutputStream with little endian byte order.
  final outputStream = OutputStream(byteOrder: LITTLE_ENDIAN);

  // Encode the archive into bytes with the highest compression level.
  final bytes = encoder.encode(archive,
      level: Deflate.BEST_COMPRESSION, output: outputStream);

  // Save the encoded bytes to a file
  await FileSaver.saveFile(
    bytes: Uint8List.fromList(bytes!),
    title: "Save Particle Configs",
    filename: "${filename ?? "configs"}.zip",
  );
}
