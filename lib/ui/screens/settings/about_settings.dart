
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DependenciesScreen extends StatelessWidget {
  const DependenciesScreen({super.key});

  final List<Map<String, String>> deps = const [
    {'name': 'Fleather', 'url': 'https://github.com/ueman/fleather', 'desc': 'Rich text editor for Flutter.'},
    {'name': 'Hive', 'url': 'https://github.com/hivedb/hive', 'desc': 'Lightweight and fast NoSQL database.'},
    {'name': 'Dynamic Color', 'url': 'https://github.com/material-foundation/material-dynamic-color-flutter', 'desc': 'Material You support for Android.'},
    {'name': 'Share Plus', 'url': 'https://github.com/fluttercommunity/plus_plugins', 'desc': 'Share content via the platform UI.'},
    {'name': 'URL Launcher', 'url': 'https://github.com/flutter/packages', 'desc': 'Launch URLs from the app.'},
    {'name': 'Animations', 'url': 'https://github.com/flutter/packages', 'desc': 'High-quality pre-built animations.'},
    {'name': 'Path Provider', 'url': 'https://github.com/flutter/plugins', 'desc': 'Access to common file system locations.'},
    {'name': 'Intl', 'url': 'https://github.com/dart-lang/i18n', 'desc': 'Internationalization and localization.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dependencies', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Packages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
          ),
          ...deps.map((item) => ListTile(
            title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(item['desc']!, style: const TextStyle(fontSize: 13)),
            trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
            onTap: () => _launchURL(item['url']!),
          )),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('View Licenses'),
            subtitle: const Text('Full legal information for used software'),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'f.Sentence',
                applicationVersion: '0.8.7-beta',
              );
            },
          ),
        ],
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