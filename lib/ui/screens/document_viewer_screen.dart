import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:parchment/parchment.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/app_settings.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String? fileName;
  final dynamic documentKey;
  final AppSettings? settings;

  const DocumentViewerScreen({
    super.key, 
    this.fileName, 
    this.documentKey,
    this.settings,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  FleatherController? _controller;
  late Box _box;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _box = Hive.box('documents_box');
    _loadDocument();
    _controller?.addListener(_autoSave);
  }

  void _loadDocument() {
    // Ako nema ključa (što se ne bi smelo desiti sad), fallback na default
    final dynamic key = widget.documentKey ?? "temp_note";
    final dynamic savedData = _box.get(key);

    if (savedData != null) {
      try {
        if (savedData is String) {
          final doc = ParchmentDocument.fromJson(jsonDecode(savedData));
          _controller = FleatherController(document: doc);
        } else {
          _controller = FleatherController();
        }
      } catch (e) {
        _controller = FleatherController();
      }
    } else {
      // Ako je nova beleška, kreiramo prazan kontroler
      _controller = FleatherController();
    }
  }

  void _autoSave() {
    if (_controller == null) return;
    final dynamic key = widget.documentKey ?? "temp_note";
    
    // Čuvamo samo ako dokument nije potpuno prazan (da ne bi punili bazu smećem)
    final delta = _controller!.document.toDelta();
    if (delta.length > 1 || delta.first.data != "\n") {
       final deltaData = jsonEncode(delta);
       _box.put(key, deltaData);
    }
  }

  void _shareDocument() {
    if (_controller == null) return;
    final String plainText = _controller!.document.toPlainText();
    final String title = widget.fileName ?? 'Untitled Note';

    if (plainText.trim().isNotEmpty) {
      Share.share(plainText, subject: title);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot share an empty note"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardVisible = bottomInset > 0;
    final safeBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          widget.fileName ?? 'f.Sentence',
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share note',
            onPressed: _shareDocument,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                child: FleatherEditor(
                  controller: _controller!,
                  focusNode: _focusNode,
                  readOnly: false,
                  enableInteractiveSelection: true,
                  padding: EdgeInsets.only(
                    top: 16, 
                    bottom: isKeyboardVisible ? bottomInset + 80 : 100,
                  ),
                ),
              ),
            ),
          ),

          // Toolbar "Pilula"
          Positioned(
            bottom: isKeyboardVisible 
                ? bottomInset + 16 
                : safeBottomPadding + 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: FleatherToolbar.basic(
                      controller: _controller!,
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