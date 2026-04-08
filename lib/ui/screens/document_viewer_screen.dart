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

  // --- EMBED BUILDER (Ključno za prikaz slika/videa) ---
  Widget _embedBuilder(BuildContext context, EmbedNode node) {
    if (node.value.type == 'image') {
      final String source = node.value.data['source'];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(File(source), fit: BoxFit.cover),
        ),
      );
    } else if (node.value.type == 'video') {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Icon(Icons.play_circle_fill, size: 50)),
      );
    } else if (node.value.type == 'audio') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.audiotrack),
            SizedBox(width: 12),
            Text("Audio fajl ubačen"),
          ],
        ),
      );
    }
    return defaultFleatherEmbedBuilder(context, node);
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

      if (filePath != null && _controller != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = p.basename(filePath);
        final localFile = await File(filePath).copy('${appDir.path}/$fileName');

        final index = _controller!.selection.baseOffset;
        final length = _controller!.selection.extentOffset - index;
        
        _controller!.document.replace(
          index, 
          length, 
          BlockEmbed(type, data: {'source': localFile.path})
        );
        _showSnackBar("Added: $type");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
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
            const Text("Add multimedia", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _mediaOption(Icons.image_rounded, "Image", () => _pickMedia('image')),
                _mediaOption(Icons.videocam_rounded, "Video", () => _pickMedia('video')),
                _mediaOption(Icons.audiotrack_rounded, "Audio", () => _pickMedia('audio')),
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
      onTap: () { Navigator.pop(context); onTap(); },
      child: Column(
        children: [
          CircleAvatar(radius: 30, child: Icon(icon, size: 28)),
          const SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }

  // --- AKCIJE ---
  Future<void> _downloadNote() async {
    try {
      final text = _controller!.document.toPlainText().trim();
      Directory? directory = Platform.isAndroid 
          ? Directory('/storage/emulated/0/Download') 
          : await getApplicationDocumentsDirectory();
      
      final filePath = '${directory.path}/$_currentTitle.txt';
      await File(filePath).writeAsString(text);
      _showSnackBar("Saved to Downloads");
    } catch (e) {
      _showSnackBar("Error: $e");
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
        title: const Text('Rename'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {
            setState(() => _currentTitle = controller.text.trim());
            _autoSave();
            Navigator.pop(context);
          }, child: const Text('Sačuvaj')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardVisible = bottomInset > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: GestureDetector(onTap: _renameNote, child: Text(_currentTitle)),
        actions: [
          IconButton(icon: const Icon(Icons.attachment_rounded), onPressed: _showMediaPicker),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(leading: const Icon(Icons.share), title: const Text("Share"), onTap: () => Share.share(_controller!.document.toPlainText())),
                  ListTile(leading: const Icon(Icons.file_download), title: const Text("Download"), onTap: _downloadNote),
                ],
              ),
            );
          }),
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
                embedBuilder: _embedBuilder, // DODATO: Ovo omogućava vidljivost slika
                padding: EdgeInsets.only(top: 16, bottom: isKeyboardVisible ? bottomInset + 100 : 140),
              ),
            ),
          ),
          Positioned(
            bottom: isKeyboardVisible ? bottomInset + 16 : 32,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(32),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _showMediaPicker),
                    const VerticalDivider(indent: 16, endIndent: 16, width: 20),
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