import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  // Metoda da dobijemo putanju do foldera gde su dokumenti
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Metoda za čuvanje fajla po imenu
  static Future<void> saveFile(String fileName, String content) async {
    final path = await _localPath;
    final file = File('$path/$fileName');
    await file.writeAsString(content);
  }

  // Metoda za čitanje fajla
  static Future<String> readFile(String fileName) async {
    try {
      final path = await _localPath;
      final file = File('$path/$fileName');
      if (await file.exists()) {
        return await file.readAsString();
      }
      return "";
    } catch (e) {
      return "";
    }
  }
}
