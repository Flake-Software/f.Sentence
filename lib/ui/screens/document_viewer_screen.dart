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
    } else {
      _controller = FleatherController();
    }
    _controller?.addListener(_autoSave);
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

  // --- IMPROVED EMBED BUILDER ---
  Widget _embedBuilder(BuildContext context, EmbedNode node) {
    if (node.value.type == 'image') {
      final String source = node.value.data['source'];
      return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(source),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
              ),
            ),
            _buildRemoveButton(node),
          ],
        ),
      );
    } else if (node.value.type == 'video' || node.value.type == 'audio') {
      final isVideo = node.value.type == 'video';
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(isVideo ? Icons.movie_creation_outlined : Icons.audiotrack_outlined),
            const SizedBox(width: 12),
            Expanded(child: Text(isVideo ? "Video Clip" : "Audio Track")),
            _buildRemoveButton(node),
          ],
        ),
      );
    }
    return defaultFleatherEmbedBuilder(context, node);
  }

  Widget _buildRemoveButton(EmbedNode node) {
    return IconButton.filledTonal(
      icon: const Icon(Icons.close, size: 18),
      onPressed: () {
        final offset = node.offset;
        _controller!.replaceText(offset, 1, '');
      },
    );
  }

  // --- MULTIMEDIA LOGIC ---
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

        // Get current selection
        int index = _controller!.selection.baseOffset;
        
        // Ensure index is within bounds
        if (index < 0) index = _controller!.document.length - 1;

        // CRITICAL: We use replaceText on the controller to ensure internal state updates
        _controller!.replaceText(
          index, 
          0, 
          BlockEmbed(type, data: {'source': localFile.path}),
          selection: TextSelection.collapsed(offset: index + 1),
        );

        _showSnackBar("Inserted $type");
      }
    } catch (e) {
      _showSnackBar("Failed to insert media: $e");
    }
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add Media", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _mediaOption(Icons.image_rounded, "Image", () => _pickMedia('image')),
                  _mediaOption(Icons.videocam_rounded, "Video", () => _pickMedia('video')),
                  _mediaOption(Icons.audiotrack_rounded, "Audio", () => _pickMedia('audio')),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: () { Navigator.pop(context); onTap(); },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          CircleAvatar(radius: 30, child: Icon(icon, size: 28)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // --- ACTIONS ---
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating)
    );
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
          ElevatedButton(onPressed: () {
            setState(() => _currentTitle = controller.text.trim());
            _autoSave();
            Navigator.pop(context);
          }, child: const Text('Save')),
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
              builder: (context) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.share_outlined), 
                      title: const Text("Share"), 
                      onTap: () {
                        Navigator.pop(context);
                        Share.share(_controller!.document.toPlainText());
                      }
                    ),
                    ListTile(
                      leading: const Icon(Icons.file_download_outlined), 
                      title: const Text("Download"), 
                      onTap: () {
                        Navigator.pop(context);
                        _downloadNote();
                      }
                    ),
                  ],
                ),
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
                embedBuilder: _embedBuilder,
                padding: EdgeInsets.only(
                  top: 16, 
                  bottom: isKeyboardVisible ? bottomInset + 100 : 140
                ),
              ),
            ),
          ),
          Positioned(
            bottom: isKeyboardVisible ? bottomInset + 16 : 32,
            left: 16,
            right: 16,
            child: Hero(
              tag: 'toolbar',
              child: Material(
                elevation: 6,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(32),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline), 
                        onPressed: _showMediaPicker,
                        color: theme.colorScheme.primary,
                      ),
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