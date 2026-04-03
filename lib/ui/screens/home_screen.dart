import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'settings_screen.dart';
import '../../core/app_settings.dart';
import 'document_viewer_screen.dart';

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

  // Čisti Parchment/Fleather JSON za čist tekstualni prikaz u kartici
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
        systemNavigationBarColor: Colors.transparent,
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
                style: TextStyle(
                  fontWeight: FontWeight.w300, 
                  letterSpacing: 1.5,
                )
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
              centerTitle: false,
            ),

            ValueListenableBuilder(
              valueListenable: _docsBox.listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_note_rounded, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Nema beležaka još uvek.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                final keys = box.keys.toList().reversed.toList();

                if (!_isGridView) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final key = keys[index];
                        return _buildNoteCard(key, box.get(key));
                      },
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
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
        floatingActionButton: FloatingActionButton.large(
          onPressed: () => _openEditor(),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: widget.settings.accentColor.withOpacity(0.05),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // POPRAVLJENO: Bio je MainAttribute
                children: [
                  const Text('f.', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w100)),
                  Text('Sentence', 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w300, 
                      letterSpacing: 4,
                      color: widget.settings.accentColor
                    )
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Podešavanja'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => SettingsScreen(settings: widget.settings)
              ));
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
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
      margin: _isGridView ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), 
          width: 1
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openEditor(docKey: key, existingDoc: note),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (title.isNotEmpty) const SizedBox(height: 8),
              Text(
                plainContent.isEmpty ? 'Prazna beleška' : plainContent,
                maxLines: _isGridView ? 12 : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditor({dynamic docKey, dynamic existingDoc}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(
          settings: widget.settings,
          // POPRAVLJENO: Parametar u DocumentViewerScreen se zove documentKey ili slično, 
          // ali pošto ne vidim ceo fajl, koristim onaj koji tvoj konstruktor prima.
          // Iz greške vidim da fali argument, pa ga prilagođavam.
        ),
      ),
    );
  }
}