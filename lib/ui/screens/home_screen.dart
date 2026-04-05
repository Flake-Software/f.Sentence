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

  // Pomaže da se "očisti" JSON iz editora za preview kartice
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
    // Prisilno resetujemo status bar svaki put kada se Home renderuje
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark 
          ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Theme.of(context).colorScheme.surface,
    ));

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: CustomScrollView(
        // Dodajemo key samom ScrollView-u da se osveži pri povratku
        key: ValueKey('HomeScroll_$_isGridView'),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            title: const Text(
              'f.Sentence', 
              style: TextStyle(fontWeight: FontWeight.w400)
            ),
            actions: [
              IconButton(
                // Promena ikonice zavisno od stanja
                icon: Icon(_isGridView ? Icons.view_agenda_outlined : Icons.grid_view_outlined),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
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
                  child: Center(
                    child: Text('Nema beležaka', style: TextStyle(color: Colors.grey))
                  ),
                );
              }

              final keys = box.keys.toList().reversed.toList();

              // Prikaz Liste
              if (!_isGridView) {
                return SliverPadding(
                  padding: const EdgeInsets.only(top: 8),
                  sliver: SliverList(
                    key: const ValueKey('ListView'),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildNoteCard(keys[index], box.get(keys[index])),
                      childCount: keys.length,
                    ),
                  ),
                );
              }

              // Prikaz Grida (Quillpad/Keep stil)
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                sliver: SliverMasonryGrid.count(
                  key: const ValueKey('GridView'), // KRITIČNO: Force refresh layouta
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
          
          // Obezbeđujemo padding na dnu da FAB ne smeta poslednjoj belešci
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      
      // FAB je van CustomScrollView-a, tako da ne bi smeo da "puca"
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
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
      key: ValueKey('Note_$key'),
      elevation: 0,
      margin: _isGridView ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), 
          width: 1
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openEditor(),
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
                maxLines: _isGridView ? 10 : 3,
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

  void _openEditor() {
    // Navigacija bez parametara jer smo utvrdili da DocumentViewerScreen 
    // verovatno ima problem sa njihovim primanjem u konstruktoru trenutno
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(
          settings: widget.settings,
        ),
      ),
    ).then((_) {
      // Kada se vratimo iz editora, forsiramo rebuild da osvežimo stanje
      setState(() {});
    });
  }
}