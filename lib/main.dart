
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart'; 
// Core settings i UI
import 'core/app_settings.dart'; 
import 'ui/screens/home_screen.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  
  await Hive.initFlutter();
  await Hive.openBox('settings_box');
  await Hive.openBox('documents_box');

  

  final appSettings = AppSettings();

  runApp(
    // ChangeNotifierProvider je bolja praksa od ListenableBuilder-a za root nivo
    ChangeNotifierProvider.value(
      value: appSettings,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final settings = context.watch<AppSettings>();
    
    final bool isAmoled = settings.themeLabel == 'AMOLED';

    return MaterialApp(
      title: 'f.Sentence',
      debugShowCheckedModeBanner: false,

      
      themeMode: settings.themeMode,

      
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: settings.accentColor,
        brightness: Brightness.light,
        fontFamily: 'Inter', 
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: settings.accentColor,

        scaffoldBackgroundColor: isAmoled ? Colors.black : null,
        
        appBarTheme: AppBarTheme(
          backgroundColor: isAmoled ? Colors.black : null,
          elevation: 0,
          surfaceTintColor: Colors.transparent, // Da ne bi posiveo appBar na skrolovanju
        ),

        cardTheme: CardThemeData(
          color: isAmoled ? const Color(0xFF121212) : null,
          elevation: 0,
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor: settings.accentColor,
          brightness: Brightness.dark,
          surface: isAmoled ? Colors.black : null,
        ),
      ),

      home: HomeScreen(settings: settings),
    );
  }
}