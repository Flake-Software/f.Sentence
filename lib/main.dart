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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWidgetInteractions();
    });
  }

  Future<void> _initWidgetInteractions() async {
    await HomeWidget.setAppGroupId(WidgetManager.appGroupId);

    // Cold Start provera
    final Uri? initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initialUri != null) _handleUri(initialUri);

    // Listen dok aplikacija radi
    HomeWidget.widgetClicked.listen((Uri? uri) {
      if (uri != null) _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    if (uri.toString().contains('add_note')) {
      _showNewNoteDialog();
    }
  }

  void _showNewNoteDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final TextEditingController nameController = TextEditingController(
      text: widget.appSettings.defaultName
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Nova bilješka"),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Unesite naslov...",
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) => _confirmNewNote(context, value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Otkaži")),
          FilledButton(
            onPressed: () => _confirmNewNote(context, nameController.text),
            child: const Text("Kreiraj"),
          ),
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
        final bool isAmoled = widget.appSettings.themeLabel == 'AMOLED';
        return MaterialApp(
          title: 'f.Sentence',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: widget.appSettings.themeMode,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: widget.appSettings.accentColor),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: widget.appSettings.accentColor,
            scaffoldBackgroundColor: isAmoled ? Colors.black : null,
            colorScheme: ColorScheme.fromSeed(
              seedColor: widget.appSettings.accentColor,
              brightness: Brightness.dark,
              surface: isAmoled ? Colors.black : null,
            ),
          ),
          home: HomeScreen(settings: widget.appSettings),
        );
      },
    );
  }
}