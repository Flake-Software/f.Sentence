import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Tvoja nova lokacija za AppSettings
import 'core/app_settings.dart'; 
import 'ui/screens/home_screen.dart';

void main() async {
  // Osiguravamo da je sve spremno pre starta
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicijalizacija baze (Hive)
  await Hive.initFlutter();
  await Hive.openBox('documents_box');
  
  // Učitavanje SharedPreferences za podešavanja
  final prefs = await SharedPreferences.getInstance();
  final appSettings = AppSettings(prefs);

  runApp(
    // ListenableBuilder sluša svaku promenu u AppSettings
    ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) {
        return MaterialApp(
          title: 'f.Sentence',
          debugShowCheckedModeBanner: false,
          
          // Biranje teme na osnovu podešavanja (System, Light, Dark)
          themeMode: appSettings.themeMode,
          
          // Svetla tema
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blueGrey,
            brightness: Brightness.light,
            fontFamily: 'Inter',
          ),
          
          // Tamna / AMOLED tema
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blueGrey,
            
            // AMOLED magija: Ako je uključen, pozadina je čisto crna
            scaffoldBackgroundColor: appSettings.isAmoled ? Colors.black : null,
            appBarTheme: AppBarTheme(
              backgroundColor: appSettings.isAmoled ? Colors.black : null,
              elevation: 0,
            ),
            
            // Kartice takođe bojimo u crno da ne odudaraju previše
            cardTheme: CardTheme(
              color: appSettings.isAmoled ? const Color(0xFF0D0D0D) : null,
            ),
            
            
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.dark,
              surface: appSettings.isAmoled ? Colors.black : null,
            ),
          ),
          

          home: HomeScreen(settings: appSettings),
        );
      },
    ),
  );
}
