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
      // Novi format: Map sa title i content
      _currentTitle = data['title'] ?? _currentTitle;
      try {
        final doc = ParchmentDocument.fromJson(jsonDecode(data['content']));
        _controller = FleatherController(document: doc);
      } catch (e) {
        _controller = FleatherController();
      }
    } else if (data is String) {
      // Stari format: Samo Delta string
      try {
        final doc = ParchmentDocument.fromJson(jsonDecode(data));
        _controller = FleatherController(document: doc);
      } catch (e) {
        _controller = FleatherController();
      }
    } else {
      // Nova beleška
      _controller = FleatherController();
    }
  }

  void _autoSave() {
    if (_controller == null) return;
    
    final content = jsonEncode(_controller!.document.toDelta());
    // Čuvamo kao Map da bi HomeScreen mogao da izvuče naslov i vreme
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_currentTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              title: const Text('Download (Coming Soon)'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                _box.delete(widget.documentKey);
                Navigator.pop(context); // Zatvori menu
                Navigator.pop(context); // Vrati se na Home
              },
            ),
            const SizedBox(height: 8),
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
          // Editor površina
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
                    bottom: isKeyboardVisible ? bottomInset + 80 : 100,
                  ),
                ),
              ),
            ),
          ),

          // VRACENA PILULA (Toolbar)
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