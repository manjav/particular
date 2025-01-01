import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class FileSaver {
  /// Saves a file to the user's device.
  /// Returns the saved file path.
  static Future<String?> saveFile({
    required String title,
    required Uint8List bytes,
    required String filename,
  }) =>
      FilePicker.platform.saveFile(
        bytes: bytes,
        dialogTitle: title,
        fileName: filename,
      );
}
