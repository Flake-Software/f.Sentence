import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'ui/screens/home_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('documents_box');
  runApp(const FSentenceApp());
}

class FSentenceApp extends StatelessWidget {
  const FSentenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
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
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            textTheme: const TextTheme(
              headlineLarge: TextStyle(fontWeight: FontWeight.w300),
              headlineMedium: TextStyle(fontWeight: FontWeight.w300),
              titleLarge: TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            textTheme: const TextTheme(
              headlineLarge: TextStyle(fontWeight: FontWeight.w300),
              headlineMedium: TextStyle(fontWeight: FontWeight.w300),
              titleLarge: TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
          themeMode: ThemeMode.system, 
          home: const HomeScreen(),
        );
      },
    );
  }
}
