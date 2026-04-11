import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/app_settings.dart';

class TrashScreen extends StatefulWidget {
  final AppSettings settings;
  const TrashScreen({super.key, required this.settings});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late Box _docsBox;

  @override
  void initState() {
    super.initState();
    _docsBox = Hive.box('documents_box');
  }

  // --- TEXT EXTRACTION ---
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

  // --- TRASH ACTIONS ---
  Future<void> _restoreNote(dynamic key) async {
    final doc = _docsBox.get(key);
    if (doc is Map) {
      final newDoc = Map<String, dynamic>.from(doc);
      newDoc['is_deleted'] = false; // Logic flag for trash
      await _docsBox.put(key, newDoc);
      _showSnackBar("Note restored");
    }
  }

  Future<void> _deletePermanently(dynamic key) async {
    await _docsBox.delete(key);
    _showSnackBar("Note permanently deleted");
  }

  Future<void> _emptyTrash() async {
    final trashKeys = _docsBox.keys.where((key) {
      final doc = _docsBox.get(key);
      return doc is Map && doc['is_deleted'] == true;
    }).toList();

    if (trashKeys.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash?'),
        content: Text('All ${trashKeys.length} notes will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Empty', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (var key in trashKeys) {
        await _docsBox.delete(key);
      }
      _showSnackBar("Trash emptied");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating)
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _emptyTrash,
            tooltip: 'Empty Trash',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _docsBox.listenable(),
        builder: (context, Box box, _) {
          final trashKeys = box.keys.where((key) {
            final doc = box.get(key);
            return doc is Map && doc['is_deleted'] == true;
          }).toList().reversed.toList();

          if (trashKeys.isEmpty) {
            return _buildEmptyState();
          }

          return MasonryGridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: trashKeys.length,
            itemBuilder: (context, index) {
              final key = trashKeys[index];
              final doc = box.get(key);
              return _buildTrashCard(key, doc);
            },
          );
        },
      ),
    );
  }

  Widget _buildTrashCard(dynamic key, dynamic doc) {
    final theme = Theme.of(context);
    final String title = doc['title'] ?? 'Untitled';
    final String preview = _getPlainText(doc['content']);
    final String date = doc['last_modified'] != null 
        ? DateFormat('MMM d').format(DateTime.parse(doc['last_modified'])) 
        : '';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      color: theme.colorScheme.surfaceContainerLow.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.lineThrough),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              preview, 
              maxLines: 3, 
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6), fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.restore_from_trash_outlined, size: 20),
                  onPressed: () => _restoreNote(key),
                  tooltip: 'Restore',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever_outlined, size: 20, color: Colors.red),
                  onPressed: () => _deletePermanently(key),
                  tooltip: 'Delete Permanently',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No notes in trash', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
        ],
      ),
    );
  }
}
