import 'dart:convert';
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
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _box = Hive.box('documents_box');
    _loadDocument();
    _controller!.addListener(_autoSave);
  }

  void _loadDocument() {
    final String key = widget.fileName ?? _defaultDocName;
    final String? savedData = _box.get(key);

    if (savedData != null) {
      final doc = ParchmentDocument.fromJson(jsonDecode(savedData));
      _controller = FleatherController(document: doc);
    } else {
      _controller = FleatherController();
    }
  }

  void _autoSave() {
    final String key = widget.fileName ?? _defaultDocName;
    final deltaData = jsonEncode(_controller!.document.toDelta());
    _box.put(key, deltaData);
    debugPrint("Dokument sačuvan: ${DateTime.now()}");
  }

  @override
  Widget build(BuildContext context) {
    // Proveravamo da li je tastatura otvorena
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName ?? 'f.Sentence',
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FleatherEditor(
                    controller: _controller!,
                    focusNode: _focusNode,
                    padding: const EdgeInsets.only(bottom: 100), // Da tekst ne ide ispod pilule
                  ),
                ),
              ),
            ],
          ),

          // Pilula toolbar
          if (isKeyboardVisible)
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              left: 20,
              right: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      iconTheme: const IconThemeData(size: 20),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: FleatherToolbar.basic(
                        controller: _controller!,
                        // Isključujemo nepotrebne stvari za čistiji izgled
                        hideHeading: false,
                        hideIndentation: true,
                        hideListNumbers: true,
                      ),
                    ),
                  ),
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
    _focusNode.dispose();
    super.dispose();
  }
}