import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Your core settings logic
import 'core/app_settings.dart'; 
import 'ui/screens/home_screen.dart';

void main() async {
  // Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive and open storage box
  await Hive.initFlutter();
  await Hive.openBox('documents_box');
  
  // Load Preferences
  final prefs = await SharedPreferences.getInstance();
  final appSettings = AppSettings(prefs);

  runApp(
    // ListenableBuilder listens to changes in AppSettings (Theme, AMOLED, etc.)
    ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) {
        return MaterialApp(
          title: 'f.Sentence',
          debugShowCheckedModeBanner: false,
          
          // Theme selection based on settings (System, Light, Dark)
          themeMode: appSettings.themeMode,
          
          // Light Theme
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blueGrey,
            brightness: Brightness.light,
            fontFamily: 'Inter',
          ),
          
          // Dark / AMOLED Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blueGrey,
            
            // AMOLED Logic: Pure black background if enabled
            scaffoldBackgroundColor: appSettings.isAmoled ? Colors.black : null,
            appBarTheme: AppBarTheme(
              backgroundColor: appSettings.isAmoled ? Colors.black : null,
              elevation: 0,
            ),
            
            // Fixed: Use CardThemeData for Material 3
            cardTheme: CardThemeData(
              color: appSettings.isAmoled ? const Color(0xFF0D0D0D) : null,
            ),
            
            // Surface and background colors for AMOLED
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.dark,
              surface: appSettings.isAmoled ? Colors.black : null,
            ),
          ),
          
          // Start the App with the HomeScreen and pass the settings
          home: HomeScreen(settings: appSettings),
        );
      },
    ),
  );
}
