import 'dart:convert'; // Za jsonEncode/jsonDecode
import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:parchment/parchment.dart';
import 'package:hive/hive.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String? fileName;
  const DocumentViewerScreen({super.key, this.fileName});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  FleatherController? _controller;
  late Box _box;
  final String _defaultDocName = "novo_pisanje";

  @override
  void initState() {
    super.initState();
    _box = Hive.box('documents_box');
    _loadDocument();
    
    // Auto-save: Svaki put kad se tekst promeni, snimi u Hive
    _controller!.addListener(_autoSave);
  }

  void _loadDocument() {
    final String key = widget.fileName ?? _defaultDocName;
    final String? savedData = _box.get(key);

    if (savedData != null) {
      // Ako imamo sačuvano, učitaj taj Delta JSON
      final doc = ParchmentDocument.fromJson(jsonDecode(savedData));
      _controller = FleatherController(document: doc);
    } else {
      // Ako je prazno, kreni od nule
      _controller = FleatherController();
    }
  }

  void _autoSave() {
    final String key = widget.fileName ?? _defaultDocName;
    // Pretvaramo Delta format u JSON string
    final deltaData = jsonEncode(_controller!.document.toDelta());
    
    // Upisujemo u Hive
    _box.put(key, deltaData);
    // Print u konzolu samo da vidiš da radi dok testiraš
    debugPrint("Dokument sačuvan: ${DateTime.now()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName ?? 'f.Sentence',
          style: const TextStyle(fontWeight: FontWeight.w300), // Tvoj tanak stil
        ),
      ),
      body: Column(
        children: [
          FleatherToolbar.basic(controller: _controller!),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: FleatherEditor(
                controller: _controller!,
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
    _controller?.removeListener(_autoSave);
    _controller?.dispose();
    super.dispose();
  }
}
