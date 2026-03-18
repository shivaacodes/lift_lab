import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';
import 'package:lift_lab/services/haptics_service.dart';
import 'package:lift_lab/widgets/app_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _databaseService = DatabaseService();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _entered = true);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool get _isPasswordValid {
    return _passwordController.text.trim().length >= 6;
  }

  String _friendlyError(Object error) {
    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    final msg = raw.toLowerCase();
    if (msg.contains('wrong-password') || msg.contains('invalid-credential')) return 'Incorrect email or password.';
    if (msg.contains('user-not-found')) return 'No account found for this email.';
    if (msg.contains('email-already-in-use')) return 'This email is already registered.';
    if (msg.contains('weak-password')) return 'Password is too weak.';
    if (msg.contains('network')) return 'Network error. Try again.';
    return raw.isEmpty ? 'Something went wrong.' : raw;
  }

  Future<void> _submit() async {
    if (!_isEmailValid || !_isPasswordValid) {
      HapticsService.error();
      if (mounted) showBottomToast(context, 'Enter a valid email and password.');
      return;
    }

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        await _authService.signInWithEmail(email, password);
        if (!mounted) return;
        final user = _authService.currentUser;
        if (user == null) return;
        final profile = await _databaseService.getUserProfile(user.uid);
        if (!mounted) return;
        HapticsService.success();
        Navigator.of(context).pushReplacementNamed(profile != null ? '/home' : '/onboarding');
        return;
      }

      await _authService.signUpWithEmail(email, password);
      if (!mounted) return;
      HapticsService.success();
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } catch (e) {
      if (!mounted) return;
      HapticsService.error();
      showBottomToast(context, _friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final canSubmit = _isEmailValid && _isPasswordValid && !_isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              
              // ── Logo/Title ──────────────────────────────────────────
              Hero(
                tag: 'logo',
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [colors.primary, colors.secondary]),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'LiftLab',
                      style: GoogleFonts.poppins(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 60),

              // ── Header Text ──────────────────────────────────────────
              AnimatedOpacity(
                opacity: _entered ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    Text(
                      _isLogin ? 'Welcome Back' : 'Get Started',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Sign in to your account' : 'Build your personalized fit life',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black45, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ── Form ────────────────────────────────────────────────
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'EMAIL ADDRESS',
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 40),

              // ── Submit Button ───────────────────────────────────────
              ElevatedButton(
                onPressed: canSubmit ? () { HapticsService.medium(); _submit(); } : null,
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                    : Text(_isLogin ? 'SIGN IN' : 'CREATE ACCOUNT'),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: _isLoading ? null : () { 
                  HapticsService.selection();
                  setState(() => _isLogin = !_isLogin); 
                },
                child: Text(
                  _isLogin ? "Don't have an account? Create one" : "Already have an account? Sign in",
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
