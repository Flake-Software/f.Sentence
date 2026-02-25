import 'package:flutter/material.dart';
import 'document_viewer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: const Center(
        child: Text(
          "Welcome!",
          style: TextStyle(fontSize: 22),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DocumentViewerScreen(),
            ),
          );
        },
        icon: const Icon(Icons.folder_open),
        label: const Text("Open document"),
      ),
    );
  }
}
