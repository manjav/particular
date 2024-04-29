import 'dart:convert';
import 'dart:ui' as ui;

// ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:particular/particular.dart';

Future<ui.Image?> browseImage() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    withData: true,
    type: FileType.image,
  );

  if (result != null) {
    PlatformFile file = result.files.first;
    var image = await loadUIImage(file.bytes!);
    return image;
  }
  return null;
}

Future<Map<dynamic, dynamic>?> browseConfigs(List<String> extensions) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    withData: true,
    type: FileType.custom,
    allowedExtensions: extensions,
  );

  if (result != null) {
    PlatformFile file = result.files.first;
    String json = String.fromCharCodes(file.bytes!);
    return jsonDecode(json);
  }
  return null;
}

Future<void> saveConfigs({required Map configs, String? filename}) async {
  final json = jsonEncode(configs);
  final bytes = utf8.encode(json);

  if (kIsWeb) {
    // final blob = html.Blob([bytes]);
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor = html.document.createElement('a') as html.AnchorElement
    //   ..href = url
    //   ..style.display = 'none'
    //   ..download = 'configs.json';
    // html.document.body!.children.add(anchor);

    // // Download
    // anchor.click();

    // // Cleanup
    // html.document.body!.children.remove(anchor);
    // html.Url.revokeObjectUrl(url);
  } else {
    await FilePicker.platform.saveFile(
      dialogTitle: "Save Particle Configs",
      fileName: "${filename ?? "configs"}.json",
      bytes: bytes,
    );
  }
}
