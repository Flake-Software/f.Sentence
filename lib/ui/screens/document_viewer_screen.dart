import 'package:flutter/material.dart';

class DocumentViewerScreen extends StatelessWidget {
  const DocumentViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document"),
      ),
      body: const Center(
        child: Text(
          "Document Viewer",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
