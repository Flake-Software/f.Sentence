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
import 'package:open_filex/open_filex.dart';
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

  // --- REPRODUKCIJA ---
  Future<void> _openFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final result = await OpenFilex.open(path);
        if (result.type != ResultType.done) {
          _showSnackBar("Couldn't remove file: ${result.message}");
        }
      } else {
        _showSnackBar("File no longer exists on your device.");
      }
    } catch (e) {
      _showSnackBar("Error while openning: $e");
    }
  }

  // --- EMBED BUILDER ---
  Widget _embedBuilder(BuildContext context, EmbedNode node) {
    final String type = node.value.type;
    final String source = node.value.data['source'];

    if (type == 'image') {
      return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            GestureDetector(
              onTap: () => _openFile(source),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(
                  File(source),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildErrorPlaceholder("Image not found"),
                ),
              ),
            ),
            _buildRemoveButton(node),
          ],
        ),
      );
    } else if (type == 'video' || type == 'audio') {
      final isVideo = type == 'video';
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              isVideo ? Icons.play_arrow_rounded : Icons.audiotrack_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            isVideo ? "Video" : "Audio",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text("Touch to play"),
          onTap: () => _openFile(source),
          trailing: _buildRemoveButton(node, inline: true),
        ),
      );
    }
    return defaultFleatherEmbedBuilder(context, node);
  }

  Widget _buildRemoveButton(EmbedNode node, {bool inline = false}) {
    return IconButton(
      icon: Icon(
        Icons.cancel,
        size: inline ? 26 : 30,
        color: inline 
            ? Theme.of(context).colorScheme.error 
            : Colors.black.withOpacity(0.5),
      ),
      onPressed: () {
        // Precizno brisanje na osnovu trenutnog offset-a čvora
        final offset = node.offset;
        final length = node.length;
        _controller!.replaceText(offset, length, '',
            selection: TextSelection.collapsed(offset: offset));
      },
    );
  }

  Widget _buildErrorPlaceholder(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- MULTIMEDIJA ---
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
        final extension = p.extension(filePath);
        final fileName = "file_${DateTime.now().millisecondsSinceEpoch}$extension";
        final localFile = await File(filePath).copy('${appDir.path}/$fileName');

        int index = _controller!.selection.baseOffset;
        if (index < 0) index = _controller!.document.length - 1;

        // Ubacivanje embed objekta
        _controller!.replaceText(
          index, 
          0, 
          BlockEmbed(type, data: {'source': localFile.path}),
          selection: TextSelection.collapsed(offset: index + 1),
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
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Insert attachment", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _mediaOption(Icons.image_outlined, "Slika", () => _pickMedia('image')),
                  _mediaOption(Icons.videocam_outlined, "Video", () => _pickMedia('video')),
                  _mediaOption(Icons.audiotrack_outlined, "Audio", () => _pickMedia('audio')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: () { Navigator.pop(context); onTap(); },
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32, 
            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            child: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary)
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // --- AKCIJE ---
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        behavior: SnackBarBehavior.floating, 
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      )
    );
  }

  Future<void> _renameNote() async {
    final controller = TextEditingController(text: _currentTitle);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename note'),
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
          IconButton(icon: const Icon(Icons.add_photo_alternate_outlined), onPressed: _showMediaPicker),
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
                  bottom: isKeyboardVisible ? bottomInset + 80 : 120
                ),
              ),
            ),
          ),
          Positioned(
            bottom: isKeyboardVisible ? bottomInset + 12 : 24,
            left: 12,
            right: 12,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(32),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attachment_rounded), 
                      onPressed: _showMediaPicker,
                      color: theme.colorScheme.primary,
                    ),
                    const VerticalDivider(width: 24, indent: 16, endIndent: 16),
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