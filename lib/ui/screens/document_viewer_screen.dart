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

  const DocumentViewerScreen({super.key, this.fileName, this.documentKey, this.settings});

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
      final doc = ParchmentDocument.fromJson(jsonDecode(data['content']));
      _controller = FleatherController(document: doc);
    } else {
      _controller = FleatherController();
    }
  }

  void _autoSave() {
    final content = jsonEncode(_controller!.document.toDelta());
    _box.put(widget.documentKey, {
      'title': _currentTitle,
      'content': content,
      'last_modified': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _renameNote() async {
    final controller = TextEditingController(text: _currentTitle);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Note'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _currentTitle = controller.text.trim());
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
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
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
              leading: const Icon(Icons.download_outlined),
              title: const Text('Download (Coming Soon)'),
              onTap: () => Navigator.pop(context),
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _renameNote,
          child: Text(_currentTitle, style: const TextStyle(fontWeight: FontWeight.w300)),
        ),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: _showMenu)],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FleatherEditor(
          controller: _controller!,
          focusNode: _focusNode,
          padding: EdgeInsets.only(top: 16, bottom: bottomInset + 100),
        ),
      ),
      
    );
  }
}