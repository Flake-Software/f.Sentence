import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/app_settings.dart';

class DocumentViewerScreen extends StatefulWidget {
  final dynamic documentKey;
  final String fileName;
  final AppSettings settings;

  const DocumentViewerScreen({
    super.key,
    required this.documentKey,
    required this.fileName,
    required this.settings,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  late Box _docsBox;
  late QuillController _controller;
  late String _currentTitle;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _docsBox = Hive.box('documents_box');
    _currentTitle = widget.fileName;
    
    final doc = _docsBox.get(widget.documentKey);
    if (doc != null && doc['content'] != null) {
      try {
        final json = jsonDecode(doc['content']);
        _controller = QuillController(
          document: Document.fromJson(json),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _controller = QuillController.basic();
      }
    } else {
      _controller = QuillController.basic();
    }
  }

  void _saveDocument() {
    final content = jsonEncode(_controller.document.toDelta().toJson());
    _docsBox.put(widget.documentKey, {
      'title': _currentTitle,
      'content': content,
      'last_modified': DateTime.now().toIso8601String(),
    });
  }

  String _getPlainText() {
    return _controller.document.toPlainText().trim();
  }

  // --- AKCIJE IZ MENIJA ---

  Future<void> _handleDownload() async {
    try {
      final text = _getPlainText();
      if (text.isEmpty) {
        _showSnackBar("Note is empty. ");
        return;
      }

      // Pronalaženje putanje (Download folder na Androidu)
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

      _showSnackBar("Saved to: $filePath");
    } catch (e) {
      _showSnackBar("Error while trying to sa: $e");
    }
  }

  void _handleRename() {
    final editController = TextEditingController(text: _currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preimenuj belešku'),
        content: TextField(controller: editController, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Otkaži')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentTitle = editController.text;
              });
              _saveDocument();
              Navigator.pop(context);
            },
            child: const Text('Sačuvaj'),
          ),
        ],
      ),
    );
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obriši belešku?'),
        content: const Text('Ova radnja se ne može poništiti.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Otkaži')),
          TextButton(
            onPressed: () {
              _docsBox.delete(widget.documentKey);
              Navigator.pop(context); // Zatvori dijalog
              Navigator.pop(context); // Vrati se na početni ekran
            },
            child: const Text('Obriši', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleShare() {
    final text = "$_currentTitle\n\n${_getPlainText()}";
    Share.share(text);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- MODAL MENU (Kao na tvojoj slici) ---

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _currentTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _handleShare();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _handleRename();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('Download (TXT)'),
              onTap: () {
                Navigator.pop(context);
                _handleDownload();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _handleDelete();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(_currentTitle, style: const TextStyle(fontWeight: FontWeight.w400)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
              if (!_isEditing) _saveDocument();
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isEditing)
            QuillSimpleToolbar(
              controller: _controller,
              configurations: const QuillSimpleToolbarConfigurations(),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: QuillEditor.basic(
                controller: _controller,
                configurations: QuillEditorConfigurations(
                  readOnly: !_isEditing,
                  placeholder: 'Write some sentences...',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}