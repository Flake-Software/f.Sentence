import 'package:flutter/material.dart';
import '../../core/storage_service.dart'; // Importuj servis

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  final TextEditingController _controller = TextEditingController();
  final String _currentFileName = "test_dokument.txt"; // Kasnije ćemo ovo prosleđivati

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  void _initLoad() async {
    String content = await StorageService.readFile(_currentFileName);
    setState(() {
      _controller.text = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextField(
          controller: _controller,
          onChanged: (text) => StorageService.saveFile(_currentFileName, text),
          maxLines: null,
          decoration: const InputDecoration(
            hintText: "Samo piši...",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
