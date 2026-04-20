import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/search_engine.dart';
import '../../core/app_settings.dart';
import 'document_viewer_screen.dart';

class NoteSearchDelegate extends SearchDelegate {
  final Box box;
  final AppSettings settings;
  late final SearchEngine _engine;

  NoteSearchDelegate({required this.box, required this.settings}) {
    _engine = SearchEngine(box);
  }

  @override
  String get searchFieldLabel => 'Search notes...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(fontWeight: FontWeight.w300),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = _engine.search(query);

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 80, color: Colors.grey.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text("Type to start searching", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied_rounded, size: 80, color: Colors.grey.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text("No results for '$query'", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final note = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          title: Text(
            note['title'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            note['content'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(Icons.description_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentViewerScreen(
                  documentKey: note['key'],
                  fileName: note['title'],
                  settings: settings,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
