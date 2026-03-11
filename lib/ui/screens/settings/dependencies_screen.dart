import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DependenciesScreen extends StatelessWidget {
  const DependenciesScreen({super.key});

  final List<Map<String, String>> deps = const [
    {'name': 'Fleather', 'url': 'https://github.com/ueman/fleather', 'desc': 'Rich text editor for Flutter.'},
    {'name': 'Hive', 'url': 'https://github.com/hivedb/hive', 'desc': 'Lightweight and fast NoSQL database.'},
    {'name': 'Dynamic Color', 'url': 'https://github.com/material-foundation/material-dynamic-color-flutter', 'desc': 'Material You support for Android.'},
    {'name': 'Easy Localization', 'url': 'https://github.com/aissat/easy_localization', 'desc': 'Multilanguage frame.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dependencies', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: ListView.builder(
        itemCount: deps.length,
        itemBuilder: (context, index) {
          final item = deps[index];
          return ListTile(
            title: Text(item['name']!),
            subtitle: Text(item['desc']!),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _launchURL(item['url']!),
          );
        },
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
