import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

import 'login_page.dart';
import 'welcome_page.dart'; // Make sure this path is correct

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Only active in debug mode
      builder: (context) => const EnvioraApp(),
    ),
  );
}

class EnvioraApp extends StatelessWidget {
  const EnvioraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enviora',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
