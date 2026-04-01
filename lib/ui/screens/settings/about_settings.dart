import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dependencies_screen.dart';

class AboutSettings extends StatelessWidget {
  const AboutSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'f.',
              style: TextStyle(fontSize: 80, fontWeight: FontWeight.w100),
            ),
            const Text(
              'Sentence',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300, letterSpacing: 4),
            ),
            const SizedBox(height: 12),
            const Text('v0.8.7-beta', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 60),

            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mission',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Creativity, yours.',
                    style: TextStyle(
                      fontSize: 16, 
                      height: 1.6, 
                      fontWeight: FontWeight.w300,
                      color: colorScheme.onSurface.withOpacity(0.8)
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            const Divider(height: 1),
            const SizedBox(height: 20),

            _buildInfoTile(
              context,
              icon: Icons.code_rounded,
              title: 'Source Code',
              subtitle: 'Check out the repository on GitHub',
              onTap: () => _launchURL('https://github.com/vaš-repo/f-sentence'),
            ),

            _buildInfoTile(
              context,
              icon: Icons.extension_outlined, // POPRAVLJENO: Malo 'e'
              title: 'Dependencies',
              subtitle: 'Third-party libraries and licenses',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DependenciesScreen()),
                );
              },
            ),

            const SizedBox(height: 60),
            Text(
              'Made with respect.',
              style: TextStyle(
                color: colorScheme.primary.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildInfoTile(BuildContext context, {
    required IconData icon, 
    required String title, 
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        onTap: onTap,
      ),
    );
  }
}