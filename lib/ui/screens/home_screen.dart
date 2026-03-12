import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/storage_service.dart';
import 'document_viewer_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _refreshList() {
    setState(() {});
  }

  Future<void> _showCreateDialog() async {
    String newFileName = "";
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Document", style: TextStyle(fontWeight: FontWeight.w300)),
          content: TextField(
            autofocus: true,
            onChanged: (value) => newFileName = value,
            decoration: const InputDecoration(
              hintText: "Enter file name",
              border: UnderlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (newFileName.isNotEmpty) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DocumentViewerScreen(
                        fileName: newFileName.endsWith('.txt') 
                            ? newFileName 
                            : '$newFileName.txt',
                      ),
                    ),
                  ).then((_) => _refreshList());
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("f.Sentence", style: TextStyle(fontWeight: FontWeight.w300)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              ),
              child: const Center(
                child: Text(
                  "f.Sentence",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w200),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ).then((_) => _refreshList());
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "v1.0.1",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<File>>(
        future: StorageService.getLocalFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text("No documents yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final files = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final fileName = file.path.split('/').last;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.article_outlined, 
                         color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  title: Text(
                    fileName,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                  subtitle: Text(
                    "Modified: ${file.lastModifiedSync().day}.${file.lastModifiedSync().month}.${file.lastModifiedSync().year}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentViewerScreen(fileName: fileName),
                      ),
                    ).then((_) => _refreshList());
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        label: const Text("New Note"),
        icon: const Icon(Icons.add),
        elevation: 2,
      ),
    );
  }
}