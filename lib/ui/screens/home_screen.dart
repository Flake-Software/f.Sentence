import 'package:flutter/material.dart';
import 'document_viewer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Centriran naslov i bez senke za čistiji izgled
      appBar: AppBar(
        title: const Text("f.Sentence", style: TextStyle(fontWeight: FontWeight.w300)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              "Nema otvorenih dokumenata",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DocumentViewerScreen(),
            ),
          );
        },
        // Koristimo zaobljene ivice (M3 stil)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add), 
        label: const Text("Započni pisanje"),
      ),
    );
  }
}
