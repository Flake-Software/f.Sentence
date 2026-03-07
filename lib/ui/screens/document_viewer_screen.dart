import 'package:flutter/material.dart';

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  // Kontroler preko kojeg upravljaš tekstom
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Izbacujemo naslov da bi bilo što čistije, ostavljamo samo Back dugme
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Ovde ćemo kasnije dodati onaj tvoj "Incognito" mod ili Share
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextField(
          controller: _controller,
          maxLines: null, // Omogućava da tekst ide u nedogled nadole
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 18, height: 1.5),
          decoration: const InputDecoration(
            hintText: "Počni da pišeš...",
            border: InputBorder.none, // Totalni minimalizam, nema onih ružnih linija
          ),
        ),
      ),
    );
  }
}
