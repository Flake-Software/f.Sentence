import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Core settings i UI
import 'core/app_settings.dart'; 
import 'ui/screens/home_screen.dart';

void main() async {
  // Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive i otvori box-ove
  await Hive.initFlutter();
  await Hive.openBox('settings_box');
  await Hive.openBox('documents_box');

  // Kreiramo AppSettings (sada bez argumenata, kako smo sredili u app_settings.dart)
  final appSettings = AppSettings();

  runApp(MyApp(appSettings: appSettings));
}

class MyApp extends StatelessWidget {
  final AppSettings appSettings;
  
  const MyApp({super.key, required this.appSettings});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder sluša promene u AppSettings bez potrebe za 'provider' paketom
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) {
        // AMOLED Logic: Proveravamo labelu teme
        final bool isAmoled = appSettings.themeLabel == 'AMOLED';

        return MaterialApp(
          title: 'f.Sentence',
          debugShowCheckedModeBanner: false,

          // Dinamički mod (System, Light, Dark)
          themeMode: appSettings.themeMode,

          // Light Theme
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: appSettings.accentColor,
            brightness: Brightness.light,
            fontFamily: 'Inter',
          ),

          // Dark / AMOLED Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: appSettings.accentColor,

            // AMOLED Specifičnosti
            scaffoldBackgroundColor: isAmoled ? Colors.black : null,
            
            appBarTheme: AppBarTheme(
              backgroundColor: isAmoled ? Colors.black : null,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),

            cardTheme: CardThemeData(
              color: isAmoled ? const Color(0xFF121212) : null,
              elevation: 0,
            ),

            colorScheme: ColorScheme.fromSeed(
              seedColor: appSettings.accentColor,
              brightness: Brightness.dark,
              surface: isAmoled ? Colors.black : null,
            ),
          ),

          // Startujemo sa HomeScreen i prosleđujemo instancu settings-a
          home: HomeScreen(settings: appSettings),
        );
      },
    );
  }
}