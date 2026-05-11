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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription? _widgetClickSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initInteractions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _widgetClickSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Čim se aplikacija vrati u fokus, proveravamo klik
    if (state == AppLifecycleState.resumed) {
      _checkForWidgetLaunch();
    }
  }

  void _initInteractions() async {
    await HomeWidget.setAppGroupId(WidgetManager.appGroupId);
    
    // Slušalac za klikove dok je aplikacija aktivna
    _widgetClickSubscription = HomeWidget.widgetClicked.listen(_handleUri);
    
    // Provera za startovanje
    _checkForWidgetLaunch();
  }

  // Koristimo kratki timer da proverimo nekoliko puta jer Androidu 
  // nekad treba vremena da "upuca" URI u proces
  void _checkForWidgetLaunch() {
    int attempts = 0;
    Timer.periodic(const Duration(milliseconds: 400), (timer) async {
      attempts++;
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null) {
        _handleUri(uri);
        timer.cancel();
      }
      if (attempts > 5) timer.cancel();
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

    // Sprečavamo duple dijaloge
    if (ModalRoute.of(context)?.settings.name == 'new_note_dialog') return;

    final controller = TextEditingController(text: widget.appSettings.defaultName);

    showDialog(
      context: context,
      barrierDismissible: true,
      routeSettings: const RouteSettings(name: 'new_note_dialog'),
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("New note"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Note name...",
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (val) => _confirm(context, val),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Otkaži")),
          FilledButton(
            onPressed: () => _confirm(context, controller.text),
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _confirm(BuildContext context, String title) {
    final String finalTitle = title.trim().isEmpty ? widget.appSettings.defaultName : title.trim();
    final String newKey = "note_${DateTime.now().millisecondsSinceEpoch}";
    
    Navigator.of(context, rootNavigator: true).pop(); // Zatvara dijalog

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
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: widget.appSettings.accentColor,
            brightness: Brightness.light,
          ),
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