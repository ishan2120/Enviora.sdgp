import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/language_selection_page.dart';
import 'pages/dashboard.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void _onLanguageSelected(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enviora',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF48702E)),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const WelcomePage(),
        '/language': (context) => LanguageSelectionPage(
              onLanguageSelected: _onLanguageSelected,
            ),
        '/home': (context) => const HomeScreen(),
      },
      initialRoute: '/',
    );
  }
}
