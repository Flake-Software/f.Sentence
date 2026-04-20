import 'dart:convert';
import 'package:hive/hive.dart';

class SearchEngine {
  final Box box;

  SearchEngine(this.box);

  /// Helper to extract plain text from Fleather/Parchment JSON
  String _getPlainText(dynamic content) {
    if (content == null) return '';
    try {
      if (content is String && content.startsWith('[')) {
        final List<dynamic> json = jsonDecode(content);
        return json.map((node) => node['insert']?.toString() ?? '').join('').trim();
      }
    } catch (e) {
      return content.toString();
    }
    return content.toString();
  }

  /// Searches through notes that are not archived or deleted
  List<Map<String, dynamic>> search(String query) {
    if (query.isEmpty) return [];

    final searchLower = query.toLowerCase();
    final results = <Map<String, dynamic>>[];

    for (var key in box.keys) {
      final doc = box.get(key);
      if (doc is Map) {
        // Skip trash and archive
        if (doc['is_deleted'] == true || doc['is_archived'] == true) continue;

        final title = (doc['title'] ?? '').toString().toLowerCase();
        final content = _getPlainText(doc['content']).toLowerCase();

        if (title.contains(searchLower) || content.contains(searchLower)) {
          results.add({
            'key': key,
            'title': doc['title'] ?? 'Untitled',
            'content': content,
            'last_modified': doc['last_modified'],
          });
        }
      }
    }
    
    // Sort by last modified
    results.sort((a, b) => (b['last_modified'] ?? '').compareTo(a['last_modified'] ?? ''));
    return results;
  }
}
