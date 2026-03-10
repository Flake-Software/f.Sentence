import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart'; // Obavezan import
import 'ui/screens/home_screen.dart'; 
import 'ui/screens/document_viewer_screen.dart';

void main() {
  runApp(const FSentenceApp());
}

class FSentenceApp extends StatelessWidget {
  const FSentenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ovo je "magija" koja izvlači boje iz sistema
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        
        // Definišemo fallback boje (ako sistem nema dynamic color)
        ColorScheme lightColorScheme = lightDynamic ?? ColorScheme.fromSeed(
          seedColor: Colors.orange,
        );
        
        ColorScheme darkColorScheme = darkDynamic ?? ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        );

        return MaterialApp(
          title: 'f.Sentence',
          debugShowCheckedModeBanner: false,
          
          // SVETLA TEMA
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            // Ovde smo "ubacili" tvoje tanke headinge
            textTheme: const TextTheme(
              headlineLarge: TextStyle(fontWeight: FontWeight.w300),
              headlineMedium: TextStyle(fontWeight: FontWeight.w300),
              titleLarge: TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
          
          // TAMNA TEMA
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            textTheme: const TextTheme(
              headlineLarge: TextStyle(fontWeight: FontWeight.w300),
              headlineMedium: TextStyle(fontWeight: FontWeight.w300),
              titleLarge: TextStyle(fontWeight: FontWeight.w300),
            ),
          ),

          // Automatski prebacuje na dark mode ako je tako na sistemu
          themeMode: ThemeMode.system, 
          
          home: const HomeScreen(),
        );
      },
    );
  }
}
