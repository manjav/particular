import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// Loads an image from the given byte array and returns it as a `ui.Image`.
///
/// The [bytes] parameter is the byte array containing the image data.
///
/// Returns a `Future<ui.Image>` that completes with the loaded image.
Future<ui.Image> loadUIImage(Uint8List bytes) async {
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}
