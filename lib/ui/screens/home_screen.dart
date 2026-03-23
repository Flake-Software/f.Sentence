import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Koristimo sllight background boju iz teme umesto onog sivila
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'f.Sentence',
          style: TextStyle(
            fontWeight: FontWeight.w300, 
            fontSize: 26,
            letterSpacing: -0.5
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(settings: widget.settings),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _docsBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return _buildEmptyState(context);
          }

          final keys = box.keys.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final dynamic docData = box.get(key);
              
              // Handle potential data formats (String for Delta or Map)
              String title = "Untitled Note";
              if (docData is Map) {
                title = docData['title'] ?? widget.settings.defaultName;
              } else if (docData is String) {
                // If it's just content, maybe use first few chars or key
                title = "Note ${index + 1}";
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () => _openNote(key, title),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Last edited: Just now", // Ovde kasnije dodaj pravi timestamp
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNote(null, widget.settings.defaultName),
        label: const Text('New Note', style: TextStyle(fontWeight: FontWeight.w500)),
        icon: const Icon(Icons.add),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Your thoughts start here',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w300,
            ),
          ),
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