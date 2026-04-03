import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'settings_screen.dart';
import '../../core/app_settings.dart';

class HomeScreen extends StatefulWidget {
  final AppSettings settings;
  const HomeScreen({super.key, required this.settings});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box _docsBox;

  @override
  void initState() {
    super.initState();
    // Otvaramo box koji smo vec inicijalizovali u main.dart
    _docsBox = Hive.box('documents_box');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Moderni Search Bar (Floating AppBar)
          SliverAppBar(
            floating: true,
            snap: true,
            title: _buildSearchBar(),
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false, // Micemo default back dugme
          ),

          // Prikaz beležaka direktno iz Hive-a
          ValueListenableBuilder(
            valueListenable: _docsBox.listenable(),
            builder: (context, Box box, _) {
              if (box.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No notes yet',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                );
              }

              final keys = box.keys.toList().reversed.toList(); // Najnovije prvo

              return SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemBuilder: (context, index) {
                    final key = keys[index];
                    final note = box.get(key);
                    // Pretpostavljam da note ima 'title' i 'content' polja
                    return _buildNoteCard(key, note);
                  },
                  childCount: keys.length,
                ),
              );
            },
          ),

          // Prostor na dnu za FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // MD3 FAB
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          // Ovde ide tvoja logika za otvaranje editora
          // npr: Navigator.push(context, MaterialPageRoute(builder: (context) => EditorPage()));
        },
        child: const Icon(Icons.add),
      ),
      
      // Donja traka sa brzim alatima
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.menu_rounded, color: Colors.grey, size: 22),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Search notes',
                style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w400),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen(settings: widget.settings)),
              ),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: widget.settings.accentColor.withOpacity(0.8),
                child: const Icon(Icons.person, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(dynamic key, dynamic note) {
    // Ako note nije Mapa, prilagodi ovo svom modelu podataka
    final String title = note['title'] ?? '';
    final String content = note['content'] ?? '';

    return GestureDetector(
      onTap: () {
        // Otvaranje postojeće beleške
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        // Boja kartice iz settings-a ili default
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (title.isNotEmpty) const SizedBox(height: 6),
              Text(
                content,
                maxLines: 10,
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

  Widget _buildBottomBar() {
    return BottomAppBar(
      height: 60,
      elevation: 0,
      color: Colors.transparent,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.check_box_outlined, size: 22), onPressed: () {}),
          IconButton(icon: const Icon(Icons.brush_outlined, size: 22), onPressed: () {}),
          IconButton(icon: const Icon(Icons.mic_none_rounded, size: 22), onPressed: () {}),
          IconButton(icon: const Icon(Icons.image_outlined, size: 22), onPressed: () {}),
        ],
      ),
    );
  }
}