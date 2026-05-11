import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';

import 'core/app_settings.dart'; 
import 'ui/screens/home_screen.dart';
import 'ui/screens/document_viewer_screen.dart';
import 'core/widgets/widget_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings_box');
  await Hive.openBox('documents_box');
  runApp(MyApp(appSettings: AppSettings()));
}

class MyApp extends StatefulWidget {
  final AppSettings appSettings;
  const MyApp({super.key, required this.appSettings});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HomeWidget.setAppGroupId(WidgetManager.appGroupId);
    HomeWidget.widgetClicked.listen(_handleUri);
    _checkForWidgetClick();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Kada se vrati iz pozadine, proveravamo više puta u kratkom razmaku
      _checkForWidgetClick();
    }
  }

  // Ponekad sistemu treba par milisekundi da "shvati" da je pokrenut preko vidžeta
  void _checkForWidgetClick() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null) {
        _handleUri(uri);
        timer.cancel();
      }
      if (timer.tick > 5) timer.cancel(); // Proveravaj max 2.5 sekunde
    });
  }

  void _handleUri(Uri? uri) {
    if (uri != null && uri.toString().contains('add_note')) {
      _showNewNoteDialog();
    }
  }

  void _showNewNoteDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    // Spreči duple dijaloge
    if (ModalRoute.of(context)?.settings.name == 'new_note_dialog') return;

    final controller = TextEditingController(text: widget.appSettings.defaultName);
    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'new_note_dialog'),
      builder: (ctx) => AlertDialog(
        title: const Text("New note"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final title = controller.text.trim();
              final key = "note_${DateTime.now().millisecondsSinceEpoch}";
              Navigator.pop(ctx);
              navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (_) => DocumentViewerScreen(
                  documentKey: key,
                  fileName: title.isEmpty ? widget.appSettings.defaultName : title,
                  settings: widget.appSettings,
                ),
              ));
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      themeMode: widget.appSettings.themeMode,
      home: HomeScreen(settings: widget.appSettings),
    );
  }
}