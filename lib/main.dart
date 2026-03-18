import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lift_lab/firebase_options.dart';
import 'package:lift_lab/theme.dart';
import 'package:lift_lab/screens/splash_screen.dart';
import 'package:lift_lab/screens/auth_screen.dart';
import 'package:lift_lab/screens/onboarding_screen.dart';
import 'package:lift_lab/main_navigation_shell.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';
import 'package:lift_lab/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(const LiftLabApp());
}

class LiftLabApp extends StatefulWidget {
  const LiftLabApp({super.key});

  @override
  State<LiftLabApp> createState() => _LiftLabAppState();
}

class _LiftLabAppState extends State<LiftLabApp> {
  late Future<FirebaseApp> _firebaseInitFuture;

  @override
  void initState() {
    super.initState();
    _firebaseInitFuture = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiftLab',
      debugShowCheckedModeBanner: false,
      theme: LiftLabTheme.lightTheme,
      darkTheme: LiftLabTheme.darkTheme,
      themeMode: ThemeMode.light,
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routes: {
        '/login': (_) => const AuthScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const MainNavigationShell(),
      },
      home: _AppGate(
        firebaseInitFuture: _firebaseInitFuture,
        onRetryFirebaseInit: () {
          setState(() {
            _firebaseInitFuture = Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            );
          });
        },
      ),
    );
  }
}

class _AppGate extends StatelessWidget {
  const _AppGate({
    required this.firebaseInitFuture,
    required this.onRetryFirebaseInit,
  });

  final Future<FirebaseApp> firebaseInitFuture;
  final VoidCallback onRetryFirebaseInit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: firebaseInitFuture,
      builder: (context, firebaseSnapshot) {
        if (firebaseSnapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }

        if (firebaseSnapshot.hasError) {
          return _InitErrorView(onRetry: onRetryFirebaseInit);
        }

        final authService = AuthService();
        final databaseService = DatabaseService();

        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            final user = authSnapshot.data;
            if (user == null) {
              return const AuthScreen();
            }

            return StreamBuilder(
              stream: databaseService.getUserProfileStream(user.uid),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SplashScreen();
                }

                final profile = profileSnapshot.data;
                if (profile == null) {
                  return const OnboardingScreen();
                }
                return const MainNavigationShell();
              },
            );
          },
        );
      },
    );
  }
}

class _InitErrorView extends StatelessWidget {
  const _InitErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize app services',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Check your network and Firebase configuration.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
