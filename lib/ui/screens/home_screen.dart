import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'document_viewer_screen.dart';
import 'settings_screen.dart';

enum ViewMode { grid, list, compact }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ViewMode _viewMode = ViewMode.grid;
  String _sortBy = 'name'; // 'name' ili 'date'
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      final modeIndex = _prefs.getInt('view_mode') ?? 0;
      _viewMode = ViewMode.values[modeIndex];
      _sortBy = _prefs.getString('sort_by') ?? 'name';
    });
  }

  void _toggleViewMode() {
    setState(() {
      int nextIndex = (_viewMode.index + 1) % ViewMode.values.length;
      _viewMode = ViewMode.values[nextIndex];
      _prefs.setInt('view_mode', nextIndex);
    });
  }

  String _getPreviewText(dynamic rawJson) {
    try {
      if (rawJson == null) return "";
      final delta = jsonDecode(rawJson as String);
      final List ops = delta is Map ? delta['ops'] : [];
      String text = ops.map((op) => op['insert']?.toString() ?? "").join();
      return text.trim().replaceAll('\n', ' ');
    } catch (e) {
      return "";
    }
  }

  Future<void> _showCreateDialog() async {
    String newFileName = "";
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Note", style: TextStyle(fontWeight: FontWeight.w300)),
          content: TextField(
            autofocus: true,
            onChanged: (value) => newFileName = value,
            decoration: const InputDecoration(hintText: "Untitled Note"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                if (newFileName.isNotEmpty) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DocumentViewerScreen(fileName: newFileName)),
                  );
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("f.Sentence", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 24)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_open_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_viewMode == ViewMode.grid 
                ? Icons.grid_view_rounded 
                : _viewMode == ViewMode.list 
                    ? Icons.view_headline_rounded 
                    : Icons.view_agenda_rounded),
            onPressed: _toggleViewMode,
            tooltip: "Promeni prikaz",
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box('documents_box').listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) return _buildEmptyState();

                List keys = box.keys.toList();
                if (_sortBy == 'name') {
                  keys.sort((a, b) => a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
                }

                return _buildMainContent(keys, box);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterChip(
            label: _sortBy == 'name' ? "Name A-Z" : "Latest first",
            icon: Icons.sort_rounded,
            onTap: () {
              setState(() {
                _sortBy = _sortBy == 'name' ? 'date' : 'name';
                _prefs.setString('sort_by', _sortBy);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required IconData icon, required VoidCallback onTap}) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      shape: StadiumBorder(side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
    );
  }

  Widget _buildMainContent(List keys, Box box) {
    if (_viewMode == ViewMode.grid) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) => _noteItem(keys[index], box, isGrid: true),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: keys.length,
      itemBuilder: (context, index) => _noteItem(keys[index], box, isGrid: false),
    );
  }

  Widget _noteItem(dynamic key, Box box, {required bool isGrid}) {
    final String title = key.toString();
    final String preview = _getPreviewText(box.get(key));

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DocumentViewerScreen(fileName: title)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.article_rounded, size: 20, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                  const Icon(Icons.more_vert_rounded, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              if (_viewMode != ViewMode.compact) ...[
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    preview.isEmpty ? "No content" : preview,
                    maxLines: isGrid ? 4 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.drive_file_rename_outline_rounded, size: 80, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text("Notes will appear here", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(child: Center(child: Text("f.Sentence", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w200)))),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }
}