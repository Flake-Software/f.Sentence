import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/app_settings.dart';
import 'settings_screen.dart';
import 'document_viewer_screen.dart'; // Ne zaboravi da importuješ screen za beleške

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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'f.Sentence',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsScreen(settings: widget.settings),
                ),
              );
            },
          ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: _docsBox.listenable(),
        builder: (context, Box box, _) {
          // EMPTY STATE
          if (box.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 72,
                      color: colors.primary.withOpacity(0.6),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No notes yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the button below to create your first note.',
                      style: TextStyle(
                        color: colors.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // LIST
          final keys = box.keys.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final doc = box.get(key);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Otvori DocumentViewerScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocumentViewerScreen(
                            documentKey: key,
                            settings: widget.settings,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['title'] ?? widget.settings.defaultName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            doc['last_modified'] ?? 'Just now',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          String? noteName = await showDialog<String>(
            context: context,
            builder: (context) {
              String tempName = '';
              return AlertDialog(
                title: const Text('New Note'),
                content: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter note name',
                  ),
                  onChanged: (value) {
                    tempName = value;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (tempName.trim().isEmpty) {
                        tempName = 'Untitled Note';
                      }
                      Navigator.pop(context, tempName);
                    },
                    child: const Text('Create'),
                  ),
                ],
              );
            },
          );

          if (noteName != null) {
            final newDoc = {
              'title': noteName,
              'last_modified': DateTime.now().toString(),
              // content for Fleather/Parchment će ići ovde kasnije
            };
            final key = await _docsBox.add(newDoc);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentViewerScreen(
                  documentKey: key,
                  settings: widget.settings,
                ),
              ),
            );
          }
        },
        label: const Text('New Note'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}