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
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Hive.initFlutter();
  await Hive.openBox('settings_box');
  await Hive.openBox('documents_box');

  final appSettings = AppSettings();
  runApp(MyApp(appSettings: appSettings));
}

class MyApp extends StatefulWidget {
  final AppSettings appSettings;
  const MyApp({super.key, required this.appSettings});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  void initState() {
    super.initState();
    _setupHomeWidget();
  }

  void _setupHomeWidget() async {
    await HomeWidget.setAppGroupId(WidgetManager.appGroupId);

    // 1. Slušaj klikove dok je aplikacija aktivna ili u pozadini
    HomeWidget.widgetClicked.listen(_handleUri);

    // 2. Proveri da li je aplikacija pokrenuta klikom (Cold Start)
    final Uri? initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initialUri != null) {
      _handleUri(initialUri);
    }
  }

  void _handleUri(Uri? uri) {
    if (uri != null && uri.toString().contains('add_note')) {
      // Kratka pauza osigurava da Navigator bude spreman
      Future.delayed(const Duration(milliseconds: 300), () {
        _showNewNoteDialog();
      });
    }
  }

  void _showNewNoteDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Provera da dijalog nije već otvoren
    if (ModalRoute.of(context)?.settings.name == 'new_note_dialog') return;

    final TextEditingController nameController = TextEditingController(
      text: widget.appSettings.defaultName
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      routeSettings: const RouteSettings(name: 'new_note_dialog'),
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("New note"),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Note title...",
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          onSubmitted: (val) => _confirmNewNote(context, val),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          FilledButton(onPressed: () => _confirmNewNote(context, nameController.text), child: const Text("Create")),
        ],
      ),
    );
  }

  void _confirmNewNote(BuildContext context, String title) {
    final String finalTitle = title.trim().isEmpty ? widget.appSettings.defaultName : title.trim();
    final String newKey = "note_${DateTime.now().millisecondsSinceEpoch}";
    Navigator.of(context, rootNavigator: true).pop();
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(
          documentKey: newKey,
          fileName: finalTitle,
          settings: widget.appSettings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appSettings,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: widget.appSettings.themeMode,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: widget.appSettings.accentColor),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: widget.appSettings.accentColor,
            scaffoldBackgroundColor: widget.appSettings.themeLabel == 'AMOLED' ? Colors.black : null,
          ),
          home: HomeScreen(settings: widget.appSettings),
        );
      },
    );
  }
}