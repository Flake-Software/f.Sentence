import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:parchment/parchment.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String? fileName;
  const DocumentViewerScreen({super.key, this.fileName});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  FleatherController? _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Inicijalizujemo prazan dokument
    final doc = ParchmentDocument();
    _controller = FleatherController(document: doc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName ?? 'f.Sentence Editor'),
      ),
      body: Column(
        children: [
          // Toolbar koji korisnik vidi - samo klikne Bold/Italic
          FleatherToolbar.basic(controller: _controller!),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: FleatherEditor(
                controller: _controller!,
                focusNode: _focusNode,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
