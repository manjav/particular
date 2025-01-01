import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class FileSaver {
  /// Saves a file to the user's device.
  static Future<String?> saveFile({
    required String title,
    required Uint8List bytes,
    required String filename,
  }) async {
    assert(kIsWeb || kIsWasm);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = "data:application/octet-stream;base64,${base64Encode(bytes)}"
      ..style.display = 'none'
      ..download = filename;

    web.document.body!.appendChild(anchor);
    anchor.click();
    web.document.body!.removeChild(anchor);
    return null;
  }
}
