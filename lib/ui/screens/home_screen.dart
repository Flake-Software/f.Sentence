import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_settings.dart';
import 'settings_screen.dart';
import 'document_viewer_screen.dart';
import 'archive.dart';
import 'trash.dart';

class HomeScreen extends StatefulWidget {
  final AppSettings settings;
  const HomeScreen({super.key, required this.settings});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box _docsBox;
  bool _isGridView = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Multi-select state
  final Set<dynamic> _selectedKeys = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _docsBox = Hive.box('documents_box');
  }

  // --- TEXT EXTRACTION LOGIC ---
  String _getPlainText(dynamic content) {
    if (content == null) return '';
    try {
      if (content is String && content.startsWith('[')) {
        final List<dynamic> json = jsonDecode(content);
        return json.map((node) => node['insert']?.toString() ?? '').join('').trim();
      }
    } catch (e) {
      return content.toString();
    }
    return content.toString();
  }

  // --- BULK ACTIONS ---
  Future<void> _bulkDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text('Move ${_selectedKeys.length} notes to trash?'),
        content: const Text('You can restore them later from the Trash folder.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer),
            child: Text('Move to Trash', style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (var key in _selectedKeys) {
        final doc = _docsBox.get(key);
        if (doc is Map) {
          final newDoc = Map<String, dynamic>.from(doc);
          newDoc['is_deleted'] = true;
          await _docsBox.put(key, newDoc);
        }
      }
      _exitSelectionMode();
    }
  }

  Future<void> _bulkShare() async {
    StringBuffer bulkText = StringBuffer();
    for (var key in _selectedKeys) {
      final doc = _docsBox.get(key);
      final title = doc['title'] ?? 'Untitled';
      final content = _getPlainText(doc['content']);
      bulkText.writeln("--- $title ---");
      bulkText.writeln(content);
      bulkText.writeln("\n");
    }
    await Share.share(bulkText.toString().trim());
    _exitSelectionMode();
  }

  Future<void> _bulkDownload() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      int savedCount = 0;
      for (var key in _selectedKeys) {
        final doc = _docsBox.get(key);
        final String title = doc['title'] ?? 'Untitled_${key}';
        final text = _getPlainText(doc['content']);
        final file = File('${directory!.path}/$title.txt');
        await file.writeAsString(text);
        savedCount++;
      }

      _showSnackBar('Successfully saved $savedCount notes to Downloads.');
      _exitSelectionMode();
    } catch (e) {
      _showSnackBar('Bulk download failed: $e');
    }
  }

  void _toggleSelection(dynamic key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
        if (_selectedKeys.isEmpty) _isSelectionMode = false;
      } else {
        _selectedKeys.add(key);
        _isSelectionMode = true;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedKeys.clear();
      _isSelectionMode = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      drawer: _buildDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            scrolledUnderElevation: 0,
            backgroundColor: theme.colorScheme.surface,
            leading: _isSelectionMode 
                ? IconButton(icon: const Icon(Icons.close), onPressed: _exitSelectionMode)
                : IconButton(
                    icon: const Icon(Icons.menu_rounded), 
                    onPressed: () => _scaffoldKey.currentState?.openDrawer()
                  ),
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _isSelectionMode ? '${_selectedKeys.length} Selected' : 'f.Sentence',
                key: ValueKey(_isSelectionMode),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: _isSelectionMode ? 22 : 28,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: _isSelectionMode 
                ? [
                    IconButton(icon: const Icon(Icons.share_outlined), onPressed: _bulkShare),
                    IconButton(icon: const Icon(Icons.file_download_outlined), onPressed: _bulkDownload),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: _bulkDelete),
                    const SizedBox(width: 8),
                  ]
                : [
                    IconButton(
                      icon: Icon(_isGridView ? Icons.view_agenda_outlined : Icons.grid_view_outlined),
                      onPressed: () => setState(() => _isGridView = !_isGridView),
                    ),
                    const SizedBox(width: 8),
                  ],
          ),
          ValueListenableBuilder(
            valueListenable: _docsBox.listenable(),
            builder: (context, Box box, _) {
              // Filter out notes that are archived or deleted
              final keys = box.keys.where((key) {
                final doc = box.get(key);
                if (doc is Map) {
                  return doc['is_archived'] != true && doc['is_deleted'] != true;
                }
                return true;
              }).toList().reversed.toList();

              if (keys.isEmpty) return SliverFillRemaining(child: _buildEmptyState());

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: _isGridView 
                    ? SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemBuilder: (context, index) => _buildNoteCard(keys[index], box.get(keys[index]), true),
                        childCount: keys.length,
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildNoteCard(keys[index], box.get(keys[index]), false),
                          childCount: keys.length,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode 
          ? null 
          : FloatingActionButton.large(
              onPressed: _showNewNoteDialog,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 0,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: const Icon(Icons.add, size: 36),
            ),
    );
  }

  Widget _buildDrawer() {
    final theme = Theme.of(context);
    return NavigationDrawer(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      onDestinationSelected: (index) {
        Navigator.pop(context); // Close drawer first
        
        switch (index) {
          case 0: // Home - Already here
            break;
          case 1: // Archive
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ArchiveScreen(settings: widget.settings)),
            );
            break;
          case 2: // Trash
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TrashScreen(settings: widget.settings)),
            );
            break;
          case 3: // Settings
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen(settings: widget.settings)),
            );
            break;
        }
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 48, 16, 10),
          child: Text(
            'f.Sentence',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
              letterSpacing: -0.5,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Home'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.archive_outlined),
          selectedIcon: Icon(Icons.archive_rounded),
          label: Text('Archive'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.delete_outline_rounded),
          selectedIcon: Icon(Icons.delete_rounded),
          label: Text('Trash'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 16),
          child: Divider(),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: Text('Settings'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNoteCard(dynamic key, dynamic doc, bool isGrid) {
    final isSelected = _selectedKeys.contains(key);
    final theme = Theme.of(context);
    final String title = doc is Map ? (doc['title'] ?? 'Untitled') : 'Untitled';
    final String preview = _getPlainText(doc is Map ? doc['content'] : doc);
    final String date = (doc is Map && doc['last_modified'] != null) 
        ? DateFormat('MMM d').format(DateTime.parse(doc['last_modified'])) 
        : '';

    return AnimatedScale(
      scale: isSelected ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: 0,
        margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(
            color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outlineVariant.withOpacity(0.3),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        color: isSelected 
            ? theme.colorScheme.primaryContainer 
            : theme.colorScheme.surfaceContainerLow,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onLongPress: () => _toggleSelection(key),
          onTap: () => _isSelectionMode ? _toggleSelection(key) : _openNote(key, title),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17), 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis
                      ),
                    ),
                    if (_isSelectionMode) 
                      Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked, 
                        color: theme.colorScheme.primary, 
                        size: 24
                      )
                    else 
                      _buildPopupMenu(key, doc),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  preview.isEmpty ? 'Empty note' : preview, 
                  maxLines: isGrid ? 5 : 2, 
                  overflow: TextOverflow.ellipsis, 
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant, 
                    fontSize: 15,
                    height: 1.4
                  )
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    date, 
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(dynamic key, dynamic doc) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_vert, size: 20, color: Theme.of(context).colorScheme.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      onSelected: (val) {
        if (val == 'archive') _handleSingleArchive(key);
        if (val == 'delete') _handleSingleDelete(key);
        if (val == 'rename') _handleRename(key, doc['title'] ?? 'Untitled');
        if (val == 'share') _handleSingleShare(doc);
        if (val == 'download') _handleSingleDownload(doc);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'download', child: ListTile(leading: Icon(Icons.download_rounded), title: Text('Download'), contentPadding: EdgeInsets.zero)),
        const PopupMenuItem(value: 'rename', child: ListTile(leading: Icon(Icons.edit_rounded), title: Text('Rename'), contentPadding: EdgeInsets.zero)),
        const PopupMenuItem(value: 'share', child: ListTile(leading: Icon(Icons.share_rounded), title: Text('Share'), contentPadding: EdgeInsets.zero)),
        const PopupMenuItem(value: 'archive', child: ListTile(leading: Icon(Icons.archive_outlined), title: Text('Archive'), contentPadding: EdgeInsets.zero)),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'delete', child: ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('Move to Trash', style: TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero)),
      ],
    );
  }

  Future<void> _handleSingleArchive(dynamic key) async {
    final doc = _docsBox.get(key);
    if (doc is Map) {
      final newDoc = Map<String, dynamic>.from(doc);
      newDoc['is_archived'] = true;
      await _docsBox.put(key, newDoc);
      _showSnackBar("Note archived");
    }
  }

  Future<void> _handleSingleDelete(dynamic key) async {
    final doc = _docsBox.get(key);
    if (doc is Map) {
      final newDoc = Map<String, dynamic>.from(doc);
      newDoc['is_deleted'] = true;
      await _docsBox.put(key, newDoc);
      _showSnackBar("Note moved to trash");
    }
  }

  void _handleRename(dynamic key, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text('Rename Note'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final doc = _docsBox.get(key);
              if (doc is Map) {
                final newDoc = Map<String, dynamic>.from(doc);
                newDoc['title'] = controller.text.trim();
                _docsBox.put(key, newDoc);
              }
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSingleShare(dynamic doc) async {
    final text = "${doc['title']}\n\n${_getPlainText(doc['content'])}";
    await Share.share(text);
  }

  Future<void> _handleSingleDownload(dynamic doc) async {
    _selectedKeys.clear();
    final index = _docsBox.values.toList().indexOf(doc);
    if (index != -1) {
      _selectedKeys.add(_docsBox.keyAt(index)); 
      await _bulkDownload();
    }
  }

  Future<void> _showNewNoteDialog() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text('New Note'),
        content: TextField(controller: controller, autofocus: true, decoration: InputDecoration(hintText: widget.settings.defaultName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              String name = controller.text.trim().isEmpty ? widget.settings.defaultName : controller.text.trim();
              Navigator.pop(context);
              _openNote("note_${DateTime.now().millisecondsSinceEpoch}", name);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _openNote(dynamic key, String title) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentViewerScreen(documentKey: key, fileName: title, settings: widget.settings)));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note_rounded, size: 100, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
          const Text('Ready to write?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
        ],
      ),
    );
  }
}