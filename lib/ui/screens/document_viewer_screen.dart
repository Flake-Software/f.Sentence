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
  final String _defaultDocName = "new_note";
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
      try {
        final doc = ParchmentDocument.fromJson(jsonDecode(savedData));
        _controller = FleatherController(document: doc);
      } catch (e) {
        // Ako je fajl prazan ili korumpiran, otvori prazan editor
        _controller = FleatherController();
      }
    } else {
      _controller = FleatherController();
    }
  }

  void _autoSave() {
    final String key = widget.fileName ?? _defaultDocName;
    final deltaData = jsonEncode(_controller!.document.toDelta());
    _box.put(key, deltaData);
    debugPrint("f.Sentence: Dokument automatski sačuvan.");
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardVisible = bottomInset > 0;
    final safeBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      // Isključujemo automatski resize da bi naš Stack i Positioned radili kako treba
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          widget.fileName ?? 'f.Sentence',
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // Ovde ćemo kasnije dodati export u .txt ili .pdf
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Glavni Editor
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
                  // Padding na dnu se menja zavisno od tastature da tekst ne ostane sakriven
                  padding: EdgeInsets.only(
                    top: 16, 
                    bottom: isKeyboardVisible ? bottomInset + 80 : 100,
                  ),
                ),
              ),
            ),
          ),

          // Plutajuća "Pilula" Toolbar
          Positioned(
            // Ako tastatura nije tu, koristimo safeBottomPadding za moderne telefone (gesture bar)
            bottom: isKeyboardVisible 
                ? bottomInset + 16 
                : safeBottomPadding + 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              shadowColor: Colors.black38,
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    // Smanjujemo razmak između ikonica u toolbaru
                    buttonTheme: const ButtonThemeData(minWidth: 40),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: FleatherToolbar.basic(
                        controller: _controller!,
                        // Ovde ne dodajemo hide parametre dok ne budemo 100% sigurni
                        // u novu dokumentaciju verzije 1.26.0
                      ),
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
