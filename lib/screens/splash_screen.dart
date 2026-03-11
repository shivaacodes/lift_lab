import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LIFTLAB',
              style: GoogleFonts.poppins(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Preparing your training data...',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: colors.onSurface.withValues(alpha: 0.72),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 18),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
