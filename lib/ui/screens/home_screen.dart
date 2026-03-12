import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'document_viewer_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Funkcija za osvežavanje liste (iako Hive watch to radi automatski, ostavljamo je radi navigacije)
  void _refreshList() {
    setState(() {});
  }

  Future<void> _showCreateDialog() async {
    String newFileName = "";
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Document", style: TextStyle(fontWeight: FontWeight.w300)),
          content: TextField(
            autofocus: true,
            onChanged: (value) => newFileName = value,
            decoration: const InputDecoration(
              hintText: "Enter file name",
              border: UnderlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (newFileName.isNotEmpty) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DocumentViewerScreen(
                        fileName: newFileName,
                      ),
                    ),
                  ).then((_) => _refreshList());
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
    // Koristimo ValueListenableBuilder da bi se lista sama osvežila čim se nešto upiše u Hive
    return Scaffold(
      appBar: AppBar(
        title: const Text("f.Sentence", style: TextStyle(fontWeight: FontWeight.w300)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              ),
              child: const Center(
                child: Text(
                  "f.Sentence",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w200),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ).then((_) => _refreshList());
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "v1.0.1",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      // Ovde leži magija - slušamo 'documents_box' direktno
      body: ValueListenableBuilder(
        valueListenable: Hive.box('documents_box').listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text("No documents yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // Uzimamo sve ključeve (imena fajlova) iz baze
          final keys = box.keys.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final String fileName = keys[index].toString();

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.article_outlined, 
                         color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  title: Text(
                    fileName,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () {
                      // Brisanje iz baze
                      box.delete(fileName);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentViewerScreen(fileName: fileName),
                      ),
                    ).then((_) => _refreshList());
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        label: const Text("New Note"),
        icon: const Icon(Icons.add),
        elevation: 2,
      ),
    );
  }
}