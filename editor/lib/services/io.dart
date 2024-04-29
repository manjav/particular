import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;

Future<ui.Image> loadUIImage(Uint8List bytes) async {
  image.Image? baseSizeImage = image.decodeImage(bytes);
  image.Image resizeImage = image.copyResize(baseSizeImage!,
      height: baseSizeImage.width, width: baseSizeImage.height);
  ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(resizeImage));
  ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

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

Future<void> saveConfigs(Map configs) async {
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
      fileName: "configs.json",
      bytes: bytes,
    );
  }
}
