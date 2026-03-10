import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/storage_service.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String fileName;

  const DocumentViewerScreen({super.key, required this.fileName});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadContent();
  }

  Future<void> _loadContent() async {
    String content = await StorageService.readFile(widget.fileName);
    setState(() {
      _controller.text = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName, style: const TextStyle(fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Edit"),
            Tab(text: "Preview"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // EDITOR TAB
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              maxLines: null,
              onChanged: (text) => StorageService.saveFile(widget.fileName, text),
              decoration: const InputDecoration(
                hintText: "Start typing...",
                border: InputBorder.none,
              ),
            ),
          ),
          Markdown(
            data: _controller.text,
            selectable: true,
            padding: const EdgeInsets.all(16.0),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
