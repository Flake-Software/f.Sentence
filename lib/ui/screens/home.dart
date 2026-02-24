import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome!', style: TextStyle(fontSize: 24))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // placeholder za Open Document
          print('Open document pressed');
        },
        child: const Icon(Icons.folder_open),
      ),
    );
  }
}