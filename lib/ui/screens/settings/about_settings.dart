import 'package:flutter/material.dart';

class AboutSettings extends StatelessWidget {
  const AboutSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'f.',
                    style: TextStyle(fontSize: 80, fontWeight: FontWeight.w100),
                  ),
                  Text(
                    'Sentence',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300, letterSpacing: 4),
                  ),
                  SizedBox(height: 12),
                  Text('v1.0.0-beta', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 60),
            const Text(
              'Mission',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'A respectful tool for your thoughts. No ads, no trackers, no subscriptions. Built for portability and true creative freedom.',
              style: TextStyle(fontSize: 16, height: 1.6, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 40),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.code_rounded),
              title: const Text('Source Code'),
              subtitle: const Text('Check out the repository on GitHub'),
              onTap: () {
                // TODO: Dodaj link ka GitHub-u
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_edu_rounded),
              title: const Text('Release Schedule'),
              subtitle: const Text('v1.0.0 - April 13, 2026'),
              onTap: () {},
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Made with respect.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
