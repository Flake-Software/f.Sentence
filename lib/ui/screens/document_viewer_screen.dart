import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:parchment/parchment.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/app_settings.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String? fileName;
  final dynamic documentKey;
  final AppSettings? settings;

  const DocumentViewerScreen({
    super.key, 
    this.fileName, 
    this.documentKey, 
    this.settings
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  FleatherController? _controller;
  late Box _box;
  late String _currentTitle;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _box = Hive.box('documents_box');
    _currentTitle = widget.fileName ?? "Untitled";
    _loadDocument();
    _controller?.addListener(_autoSave);
  }

  void _loadDocument() {
    final data = _box.get(widget.documentKey);
    
    if (data != null && data is Map) {
      _currentTitle = data['title'] ?? _currentTitle;
      try {
        final doc = ParchmentDocument.fromJson(jsonDecode(data['content']));
        _controller = FleatherController(document: doc);
      } catch (e) {
        _controller = FleatherController();
      }
    } else if (data is String) {
      try {
        final doc = ParchmentDocument.fromJson(jsonDecode(data));
        _controller = FleatherController(document: doc);
      } catch (e) {
        _controller = FleatherController();
      }
    } else {
      _controller = FleatherController();
    }
  }

  void _autoSave() {
    if (_controller == null) return;
    
    final content = jsonEncode(_controller!.document.toDelta());
    _box.put(widget.documentKey, {
      'title': _currentTitle,
      'content': content,
      'last_modified': DateTime.now().toIso8601String(),
    });
  }

  // --- NOVA DOWNLOAD FUNKCIJA ---
  Future<void> _downloadNote() async {
    try {
      final text = _controller!.document.toPlainText().trim();
      if (text.isEmpty) {
        _showSnackBar("Beleška je prazna.");
        return;
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory!.path}/$_currentTitle.txt';
      final file = File(filePath);
      await file.writeAsString(text);

      _showSnackBar("Sačuvano: $_currentTitle.txt u Download folder.");
    } catch (e) {
      _showSnackBar("Greška pri čuvanju: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _renameNote() async {
    final controller = TextEditingController(text: _currentTitle);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Note'),
        content: TextField(
          controller: controller, 
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter note name..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentTitle = controller.text.trim().isEmpty 
                    ? (widget.settings?.defaultName ?? "New note") 
                    : controller.text.trim();
              });
              _autoSave();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _currentTitle, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                Share.share(_controller!.document.toPlainText(), subject: _currentTitle);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _renameNote();
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Download (TXT)'),
              onTap: () {
                Navigator.pop(context);
                _downloadNote();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                _box.delete(widget.documentKey);
                Navigator.pop(context); 
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
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
        title: GestureDetector(
          onTap: _renameNote,
          child: Text(_currentTitle, style: const TextStyle(fontWeight: FontWeight.w300)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMenu,
          )
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
                  padding: EdgeInsets.only(
                    top: 16, 
                    bottom: isKeyboardVisible ? bottomInset + 80 : 120,
                  ),
                ),
              ),
            ),
          ),

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
