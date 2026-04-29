import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';

// Core settings i UI
import 'core/app_settings.dart'; 
import 'ui/screens/home_screen.dart';
import 'ui/screens/document_viewer_screen.dart';
import 'core/widgets/widget_manager.dart';

// Global key for navigation from widget clicks
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Postavljanje transparentnosti sistemskih traka za "Edge-to-Edge" izgled
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  // Opciono: Omogućavanje Edge-to-Edge moda na Androidu
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize Hive i otvori box-ove
  await Hive.initFlutter();
  await Hive.openBox('settings_box');
  await Hive.openBox('documents_box');

  // Kreiramo AppSettings
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
    
    // Setup the listener for Home Screen Widget clicks
    WidgetManager.setupWidgetClickListener((Uri? uri) {
      if (uri != null && uri.host == 'add_note') {
        _handleWidgetAction();
      }
    });
  }

  void _handleWidgetAction() {
    // Generate a new key for the fresh note
    final String newKey = "note_${DateTime.now().millisecondsSinceEpoch}";
    
    // Navigate using the global navigator key
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(
          documentKey: newKey,
          fileName: widget.appSettings.defaultName,
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
          navigatorKey: navigatorKey, // Set the global key here
          debugShowCheckedModeBanner: false,
          themeMode: widget.appSettings.themeMode,

          // Light Theme
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: widget.appSettings.accentColor,
            brightness: Brightness.light,
            fontFamily: 'Inter',
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
            ),
          ),

          // Dark / AMOLED Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: widget.appSettings.accentColor,

            // AMOLED Specifičnosti
            scaffoldBackgroundColor: isAmoled ? Colors.black : null,

            appBarTheme: AppBarTheme(
              backgroundColor: isAmoled ? Colors.black : null,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
            ),

            cardTheme: CardThemeData(
              color: isAmoled ? const Color(0xFF121212) : null,
              elevation: 0,
            ),

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