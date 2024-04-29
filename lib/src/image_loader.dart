import 'dart:ui' as ui;
import 'package:image/image.dart' as image;
import 'package:flutter/services.dart';

/// Loads an image from the given byte array and returns it as a `ui.Image`.
///
/// The [bytes] parameter is the byte array containing the image data.
///
/// Returns a `Future<ui.Image>` that completes with the loaded image.
Future<ui.Image> loadUIImage(Uint8List bytes) async {
  image.Image? baseSizeImage = image.decodeImage(bytes);
  image.Image resizeImage = image.copyResize(baseSizeImage!,
      height: baseSizeImage.width, width: baseSizeImage.height);
  ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(resizeImage));
  ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}
