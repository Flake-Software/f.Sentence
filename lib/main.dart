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
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initInteractions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kada se korisnik vrati u aplikaciju, proveravamo da li je kliknuo na vidžet
    if (state == AppLifecycleState.resumed) {
      _checkWidgetLaunch();
    }
  }

  void _initInteractions() async {
    await HomeWidget.setAppGroupId(WidgetManager.appGroupId);
    // Slušalac dok aplikacija radi u pozadini
    HomeWidget.widgetClicked.listen(_handleUri);
    // Provera za prvo paljenje
    _checkWidgetLaunch();
  }

  Future<void> _checkWidgetLaunch() async {
    final Uri? uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) {
      _handleUri(uri);
    }
  }

  void _handleUri(Uri? uri) {
    if (uri != null && uri.toString().contains('add_note')) {
      // Mala pauza da Navigator bude spreman
      Future.delayed(const Duration(milliseconds: 350), () {
        _showNewNoteDialog();
      });
    }
  }

  void _showNewNoteDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Ako je dijalog već otvoren, ne otvaraj ponovo
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
        title: const Text("Nova bilješka"),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Naslov...",
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          onSubmitted: (val) => _confirm(context, val),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Otkaži")),
          FilledButton(onPressed: () => _confirm(context, nameController.text), child: const Text("Kreiraj")),
        ],
      ),
    );
  }

  void _confirm(BuildContext context, String title) {
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