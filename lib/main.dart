import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/language_selection_page.dart';
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart';
import 'supervisor/pages/supervisor_login_page.dart';
import 'supervisor/pages/supervisor_dashboard.dart';
import 'supervisor/widgets/supervisor_auth_guard.dart';
import 'pages/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Standard initialization for Android/iOS with service files
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  runApp(const EnvioraApp());
}

class EnvioraApp extends StatefulWidget {
  const EnvioraApp({super.key});

  @override
  State<EnvioraApp> createState() => _EnvioraAppState();
}

class _EnvioraAppState extends State<EnvioraApp> {
  Locale _locale = const Locale('en');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enviora',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('si'),
        Locale('tam'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/language': (context) =>
            LanguageSelectionPage(onLanguageSelected: _setLocale),
        '/home': (context) => const HomeScreen(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/supervisor-login': (context) => const SupervisorLoginPage(),
        '/supervisor-home': (context) => const SupervisorAuthGuard(child: SupervisorDashboard()),
      },
    );
  }
}
