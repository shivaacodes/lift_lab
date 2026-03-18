import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'logo',
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colors.primary, colors.secondary]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 48),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'LIFTLAB',
              style: GoogleFonts.poppins(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Initializing training protocols...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black26,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
