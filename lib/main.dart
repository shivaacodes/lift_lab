import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lift_lab/firebase_options.dart';
import 'package:lift_lab/theme.dart';
import 'package:lift_lab/screens/splash_screen.dart';
import 'package:lift_lab/theme_provider.dart';
import 'package:lift_lab/screens/member_dashboard.dart';
import 'package:lift_lab/screens/auth_screen.dart';
import 'package:lift_lab/screens/onboarding_screen.dart';
import 'package:lift_lab/intro_pager_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LiftLabApp());
}

class LiftLabApp extends StatelessWidget {
  const LiftLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiftLab (Emerald Midnight)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkGreenTheme,
      home: const IntroPagerScreen(),
    );
  }
}
