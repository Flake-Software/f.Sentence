import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'settings_screen.dart';
import 'document_viewer_screen.dart';
import '../../core/app_settings.dart';

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

  @override
  void initState() {
    super.initState();
    _docsBox = Hive.box('documents_box');
  }

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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark 
            ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: const Text('f.Sentence', 
                style: TextStyle(fontWeight: FontWeight.w400)
              ),
              actions: [
                IconButton(
                  icon: Icon(_isGridView ? Icons.view_agenda_outlined : Icons.grid_view_outlined),
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                ),
                const SizedBox(width: 8),
              ],
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
            ),

            ValueListenableBuilder(
              valueListenable: _docsBox.listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No notes yet', style: TextStyle(color: Colors.grey))),
                  );
                }

                final keys = box.keys.toList().reversed.toList();

                if (!_isGridView) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildNoteCard(keys[index], box.get(keys[index])),
                      childCount: keys.length,
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemBuilder: (context, index) {
                      final key = keys[index];
                      return _buildNoteCard(key, box.get(key));
                    },
                    childCount: keys.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        floatingActionButton: FloatingActionButton.large(
          onPressed: () => _openEditor(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            child: const Text(
              'f.Sentence',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => SettingsScreen(settings: widget.settings)
              ));
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('v0.8.7-beta', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(dynamic key, dynamic note) {
    final String title = note['title'] ?? '';
    final String plainContent = _getPlainText(note['content']);

    return Card(
      elevation: 0,
      margin: _isGridView ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openEditor(noteKey: key, noteData: note),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (title.isNotEmpty) const SizedBox(height: 8),
              Text(
                plainContent,
                maxLines: _isGridView ? 10 : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditor({dynamic noteKey, dynamic noteData}) {
    // Ovde koristimo parametre koje tvoj DocumentViewerScreen verovatno očekuje
    // Na osnovu prethodnih grešaka, prilagodio sam poziv da bude kompatibilan
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(
          settings: widget.settings,
        ),
      ),
    );
  }
}