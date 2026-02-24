import 'package:flutter/material.dart';
import '../core/document_service.dart';
import '../core/document_model.dart';

class DocumentScreen extends StatefulWidget {
  final String filePath;
  const DocumentScreen({required this.filePath, super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  Document? document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  void loadDocument() {
    final doc = DocumentService.loadDocx(widget.filePath);
    setState(() {
      document = doc;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (document == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('f.Sentence')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: document!.paragraphs.map((p) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              p.spans.map((s) => s.text).join(),
              style: const TextStyle(fontFamily: 'Frutiger', fontSize: 16),
            ),
          );
        }).toList(),
      ),
    );
  }
}
