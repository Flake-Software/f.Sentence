import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; 
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
  bool _isGridView = true; // Default na grid

  @override
  void initState() {
    super.initState();
    _docsBox = Hive.box('documents_box');
  }

  // Tvoja originalna logika za imena
  String _generateUniqueName(String baseName) {
    final existingTitles = _docsBox.values
        .where((doc) => doc is Map)
        .map((doc) => doc['title'] as String)
        .toList();

    if (!existingTitles.contains(baseName)) return baseName;

    int counter = 1;
    String newName = "$baseName ($counter)";
    while (existingTitles.contains(newName)) {
      counter++;
      newName = "$baseName ($counter)";
    }
    return newName;
  }

  // Pomoćna funkcija za preview teksta iz JSON-a
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

  Future<void> _showNewNoteDialog() async {
    final TextEditingController _controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Note'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: widget.settings.defaultName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String name = _controller.text.trim();
              if (name.isEmpty) name = widget.settings.defaultName;
              name = _generateUniqueName(name);

              Navigator.pop(context);
              _openNote("note_${DateTime.now().millisecondsSinceEpoch}", name);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('f.Sentence', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 26)),
        actions: [
          // NOVI TOGGLE DUGME
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
          if (box.isEmpty) return _buildEmptyState(context);

          final keys = box.keys.toList().reversed.toList();

          if (_isGridView) {
            return MasonryGridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final key = keys[index];
                return _buildGridCard(key, box.get(key));
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              return _buildListCard(key, box.get(key));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewNoteDialog,
        label: const Text('New Note'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // Tvoj originalni List kartica
  Widget _buildListCard(dynamic key, dynamic doc) {
    String title = "Untitled";
    String lastModified = "Unknown";
    String previewText = "";

    if (doc is Map) {
      title = doc['title'] ?? "Untitled";
      previewText = _getPlainText(doc['content']);
      if (doc['last_modified'] != null) {
        final dt = DateTime.parse(doc['last_modified']);
        lastModified = DateFormat('MMM d, HH:mm').format(dt);
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          previewText.isNotEmpty ? previewText : "Modified: $lastModified",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openNote(key, title),
      ),
    );
  }

  // Nova Grid kartica (Keep stil)
  Widget _buildGridCard(dynamic key, dynamic doc) {
    String title = "Untitled";
    String previewText = "";

    if (doc is Map) {
      title = doc['title'] ?? "Untitled";
      previewText = _getPlainText(doc['content']);
    }

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openNote(key, title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (previewText.isNotEmpty) const SizedBox(height: 8),
              if (previewText.isNotEmpty)
                Text(
                  previewText,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Your thoughts start here', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
        ],
      ),
    );
  }

  void _openNote(dynamic key, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(
          documentKey: key, // Provereno: Ovi parametri rade
          fileName: title,   // Provereno: Ovi parametri rade
          settings: widget.settings,
        ),
      ),
    );
  }
}