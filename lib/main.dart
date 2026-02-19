import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lift_lab/firebase_options.dart';
import 'package:lift_lab/theme.dart';
import 'package:lift_lab/screens/splash_screen.dart';
import 'package:lift_lab/screens/auth_screen.dart';
import 'package:lift_lab/screens/onboarding_screen.dart';
import 'package:lift_lab/screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LiftLabApp());
}

class LiftLabApp extends StatelessWidget {
  const LiftLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiftLab',
      debugShowCheckedModeBanner: false,
      theme: LiftLabTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const AuthScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeShell(),
      },
    );
  }
}
