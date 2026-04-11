import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'document_viewer_screen.dart';
import '../../core/app_settings.dart';

class ArchiveScreen extends StatefulWidget {
  final AppSettings settings;
  const ArchiveScreen({super.key, required this.settings});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
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

  // --- ARCHIVE ACTIONS ---
  Future<void> _unarchiveNote(dynamic key) async {
    final doc = _docsBox.get(key);
    if (doc is Map) {
      final newDoc = Map<String, dynamic>.from(doc);
      newDoc['is_archived'] = false;
      await _docsBox.put(key, newDoc);
      _showSnackBar("Note restored to main list");
    }
  }

  Future<void> _deletePermanently(dynamic key) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _docsBox.delete(key);
      _showSnackBar("Note deleted permanently");
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
        title: const Text('Archive'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: _docsBox.listenable(),
        builder: (context, Box box, _) {
          // Filter only archived notes
          final archivedKeys = box.keys.where((key) {
            final doc = box.get(key);
            return doc is Map && doc['is_archived'] == true;
          }).toList().reversed.toList();

          if (archivedKeys.isEmpty) {
            return _buildEmptyState();
          }

          return MasonryGridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: archivedKeys.length,
            itemBuilder: (context, index) {
              final key = archivedKeys[index];
              final doc = box.get(key);
              return _buildArchiveCard(key, doc);
            },
          );
        },
      ),
    );
  }

  Widget _buildArchiveCard(dynamic key, dynamic doc) {
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
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentViewerScreen(
                documentKey: key, 
                fileName: title, 
                settings: widget.settings
              )
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildPopupMenu(key),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                preview, 
                maxLines: 4, 
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                date, 
                style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(dynamic key) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (val) {
        if (val == 'unarchive') _unarchiveNote(key);
        if (val == 'delete') _deletePermanently(key);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'unarchive', 
          child: ListTile(
            leading: Icon(Icons.unarchive_outlined), 
            title: Text('Unarchive'), 
            contentPadding: EdgeInsets.zero
          )
        ),
        const PopupMenuItem(
          value: 'delete', 
          child: ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: Colors.red), 
            title: Text('Delete Permanently', style: TextStyle(color: Colors.red)), 
            contentPadding: EdgeInsets.zero
          )
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.archive_outlined, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Archive is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
        ],
      ),
    );
  }
}
