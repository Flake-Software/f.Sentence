import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/storage_service.dart';
import 'document_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Funkcija za osvežavanje liste nakon kreiranja ili brisanja
  void _refreshList() {
    setState(() {});
  }

  // Dijalog za kreiranje novog dokumenta
  Future<void> _showCreateDialog() async {
    String newFileName = "";
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Document"),
          content: TextField(
            onChanged: (value) => newFileName = value,
            decoration: const InputDecoration(hintText: "Enter file name"),
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
      ),
      body: FutureBuilder<List<File>>(
        future: StorageService.getLocalFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No documents yet.", style: TextStyle(color: Colors.grey)),
            );
          }

          final files = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final fileName = file.path.split('/').last;

              return Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text(fileName),
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
      ),
    );
  }
}
