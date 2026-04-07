import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_settings.dart';
import 'settings_screen.dart';
import 'document_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppSettings settings;
  const HomeScreen({super.key, required this.settings});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box _docsBox;
  bool _isGridView = true;
  
  // Multi-select stanje
  final Set<dynamic> _selectedKeys = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _docsBox = Hive.box('documents_box');
  }

  // --- LOGIKA ZA FAJLOVE ---

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

  void _toggleSelection(dynamic key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
        if (_selectedKeys.isEmpty) _isSelectionMode = false;
      } else {
        _selectedKeys.add(key);
        _isSelectionMode = true;
      }
    });
  }

  // --- AKCIJE IZ MENIJA ---

  Future<void> _handleDelete(dynamic key) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
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
      setState(() {});
    }
  }

  void _handleRename(dynamic key, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Note'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final doc = _docsBox.get(key);
              doc['title'] = controller.text;
              _docsBox.put(key, doc);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleShare(dynamic doc) async {
    final text = "${doc['title']}\n\n${_getPlainText(doc['content'])}";
    await Share.share(text);
  }

  Future<void> _handleDownload(dynamic doc) async {
    try {
      final text = _getPlainText(doc['content']);
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/${doc['title']}.txt');
      await file.writeAsString(text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save file')),
      );
    }
  }

  void _deleteSelected() async {
    for (var key in _selectedKeys) {
      await _docsBox.delete(key);
    }
    setState(() {
      _selectedKeys.clear();
      _isSelectionMode = false;
    });
  }

  // --- UI WIDGETI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: _isSelectionMode 
          ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _isSelectionMode = false; _selectedKeys.clear(); }))
          : null,
        title: Text(
          _isSelectionMode ? '${_selectedKeys.length} selected' : 'f.Sentence',
          style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 24),
        ),
        actions: _isSelectionMode 
          ? [IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteSelected)]
          : [
              IconButton(
                icon: Icon(_isGridView ? Icons.view_agenda_outlined : Icons.grid_view_outlined),
                onPressed: () => setState(() => _isGridView = !_isGridView),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen(settings: widget.settings)),
                ),
              ),
            ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _docsBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) return _buildEmptyState();
          final keys = box.keys.toList().reversed.toList();

          return _isGridView 
            ? MasonryGridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: keys.length,
                itemBuilder: (context, index) => _buildNoteCard(keys[index], box.get(keys[index]), true),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: keys.length,
                itemBuilder: (context, index) => _buildNoteCard(keys[index], box.get(keys[index]), false),
              );
        },
      ),
      floatingActionButton: _isSelectionMode ? null : FloatingActionButton.extended(
        onPressed: _showNewNoteDialog,
        label: const Text('New Note'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(dynamic key, dynamic doc, bool isGrid) {
    final isSelected = _selectedKeys.contains(key);
    final String title = doc['title'] ?? 'Untitled';
    final String preview = _getPlainText(doc['content']);
    final String date = doc['last_modified'] != null 
        ? DateFormat('MMM d').format(DateTime.parse(doc['last_modified'])) 
        : '';

    return Card(
      elevation: 0,
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onLongPress: () => _toggleSelection(key),
        onTap: () => _isSelectionMode ? _toggleSelection(key) : _openNote(key, title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (!_isSelectionMode) _buildPopupMenu(key, doc),
                  if (_isSelectionMode) Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: Theme.of(context).colorScheme.primary, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(preview.isEmpty ? 'Empty note' : preview, maxLines: isGrid ? 6 : 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
              const SizedBox(height: 12),
              Text(date, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(dynamic key, dynamic doc) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (val) {
        if (val == 'delete') _handleDelete(key);
        if (val == 'rename') _handleRename(key, doc['title']);
        if (val == 'share') _handleShare(doc);
        if (val == 'download') _handleDownload(doc);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'download', child: ListTile(leading: Icon(Icons.download_rounded), title: Text('Download'), contentPadding: EdgeInsets.zero)),
        const PopupMenuItem(value: 'rename', child: ListTile(leading: Icon(Icons.edit_rounded), title: Text('Rename'), contentPadding: EdgeInsets.zero)),
        const PopupMenuItem(value: 'share', child: ListTile(leading: Icon(Icons.share_rounded), title: Text('Share'), contentPadding: EdgeInsets.zero)),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero)),
      ],
    );
  }

  // --- OSTALE POMOĆNE FUNKCIJE ---

  Future<void> _showNewNoteDialog() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Note'),
        content: TextField(controller: controller, autofocus: true, decoration: InputDecoration(hintText: widget.settings.defaultName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              String name = controller.text.trim().isEmpty ? widget.settings.defaultName : controller.text.trim();
              Navigator.pop(context);
              _openNote("note_${DateTime.now().millisecondsSinceEpoch}", name);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _openNote(dynamic key, String title) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentViewerScreen(documentKey: key, fileName: title, settings: widget.settings)));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
          const Text('Ready to create?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
        ],
      ),
    );
  }
}
