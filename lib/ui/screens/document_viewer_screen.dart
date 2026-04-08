import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:parchment/parchment.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
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
  final ImagePicker _picker = ImagePicker();

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

  // --- MULTIMEDIJA LOGIKA ---

  Future<void> _pickMedia(String type) async {
    String? filePath;
    
    try {
      if (type == 'image') {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        filePath = image?.path;
      } else if (type == 'video') {
        final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
        filePath = video?.path;
      } else if (type == 'audio') {
        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
        filePath = result?.files.single.path;
      }

      if (filePath != null) {
        // Kopiramo fajl u lokalni direktorijum aplikacije da bi ostao trajan
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = p.basename(filePath);
        final localFile = await File(filePath).copy('${appDir.path}/$fileName');

        // Ubacujemo u editor kao Embed
        final index = _controller!.selection.baseOffset;
        _controller!.replace(index, 0, BlockEmbed(type, data: {'source': localFile.path}));
        _showSnackBar("Dodato: $type");
      }
    } catch (e) {
      _showSnackBar("Greška pri dodavanju medija: $e");
    }
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Dodaj Multimediju", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _mediaOption(Icons.image_rounded, "Slika", () => _pickMedia('image')),
                _mediaOption(Icons.videocam_rounded, "Video", () => _pickMedia('video')),
                _mediaOption(Icons.audiotrack_rounded, "Audio", () => _pickMedia('audio')),
                _mediaOption(Icons.gif_box_rounded, "GIF", () => _pickMedia('image')), // GIF se tretira kao slika
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _mediaOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // --- OSTALE AKCIJE ---

  Future<void> _downloadNote() async {
    try {
      final text = _controller!.document.toPlainText().trim();
      Directory? directory = Platform.isAndroid 
          ? Directory('/storage/emulated/0/Download') 
          : await getApplicationDocumentsDirectory();
      
      final filePath = '${directory.path}/$_currentTitle.txt';
      await File(filePath).writeAsString(text);
      _showSnackBar("Sačuvano u Downloads");
    } catch (e) {
      _showSnackBar("Greška: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _renameNote() async {
    final controller = TextEditingController(text: _currentTitle);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preimenuj'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Otkaži')),
          ElevatedButton(
            onPressed: () {
              setState(() => _currentTitle = controller.text.trim());
              _autoSave();
              Navigator.pop(context);
            },
            child: const Text('Sačuvaj'),
          ),
        ],
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Podeli'),
              onTap: () {
                Navigator.pop(context);
                Share.share(_controller!.document.toPlainText(), subject: _currentTitle);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Preimenuj'),
              onTap: () { Navigator.pop(context); _renameNote(); },
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Preuzmi (TXT)'),
              onTap: () { Navigator.pop(context); _downloadNote(); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Obriši', style: TextStyle(color: Colors.red)),
              onTap: () {
                _box.delete(widget.documentKey);
                Navigator.pop(context); Navigator.pop(context);
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
    final bool isKeyboardVisible = bottomInset > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: GestureDetector(
          onTap: _renameNote,
          child: Text(_currentTitle, style: const TextStyle(fontWeight: FontWeight.w300)),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.attachment_rounded), onPressed: _showMediaPicker),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: _showMenu),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FleatherEditor(
                controller: _controller!,
                focusNode: _focusNode,
                padding: EdgeInsets.only(top: 16, bottom: isKeyboardVisible ? bottomInset + 80 : 120),
              ),
            ),
          ),

          // TOOLBAR + MEDIA DUGME
          Positioned(
            bottom: isKeyboardVisible ? bottomInset + 16 : 32,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _showMediaPicker,
                    ),
                    const VerticalDivider(indent: 12, endIndent: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: FleatherToolbar.basic(controller: _controller!),
                      ),
                    ),
                  ],
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
