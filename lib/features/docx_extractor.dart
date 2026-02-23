import 'dart:io';
import 'package:archive/archive_io.dart';

class DocxExtractor {
  static String extractDocumentXml(String filePath) {
    final bytes = File(filePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      if (file.isFile && file.name == 'word/document.xml') {
        final data = file.content as List<int>;
        return String.fromCharCodes(data);
      }
    }

    throw Exception('Could not find document.xml.');
  }
}
