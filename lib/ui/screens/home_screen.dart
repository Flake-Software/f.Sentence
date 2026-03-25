import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; 
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

  @override
  void initState() {
    super.initState();
    _docsBox = Hive.box('documents_box');
  }

  // Funkcija za proveru duplikata imena (New note, New note (1)...)
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final doc = box.get(key);
              
              String title = "Untitled";
              String lastModified = "Unknown";
              
              if (doc is Map) {
                title = doc['title'] ?? "Untitled";
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
                  subtitle: Text("Modified: $lastModified", style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openNote(key, title),
                ),
              );
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
          documentKey: key,
          fileName: title,
          settings: widget.settings,
        ),
      ),
    );
  }
}