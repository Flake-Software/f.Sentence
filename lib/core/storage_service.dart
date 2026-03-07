import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  static Future<List<File>> getLocalFiles() async {
    try {
      final path = await _localPath;
      final directory = Directory(path);
      
      final List<FileSystemEntity> entities = await directory.list().toList();
      
      final List<File> files = entities
          .whereType<File>()
          .where((file) => file.path.endsWith('.txt'))
          .toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      return files;
    } catch (e) {
      return [];
    }
  }
  static Future<void> saveFile(String fileName, String content) async {
    final path = await _localPath;
    final file = File('$path/$fileName');
    await file.writeAsString(content);
  }
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
  static Future<void> deleteFile(String fileName) async {
    try {
      final path = await _localPath;
      final file = File('$path/$fileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
    }
  }
}
