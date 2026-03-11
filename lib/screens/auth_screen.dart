import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';
import 'package:lift_lab/services/haptics_service.dart';

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

    if (msg.contains('wrong-password') || msg.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    }
    if (msg.contains('user-not-found')) {
      return 'No account found for this email.';
    }
    if (msg.contains('email-already-in-use')) {
      return 'This email is already registered.';
    }
    if (msg.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (msg.contains('network') || msg.contains('socket')) {
      return 'Network error. Check your internet and try again.';
    }
    if (msg.contains('too-many-requests')) {
      return 'Too many attempts. Please wait and try again.';
    }
    return raw.isEmpty ? 'Something went wrong. Please try again.' : raw;
  }

  void _showToast({
    required String message,
    required Color backgroundColor,
    required Color foregroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: TextStyle(color: foregroundColor)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final colors = Theme.of(context).colorScheme;
    if (!_isEmailValid || !_isPasswordValid) {
      HapticsService.error();
      _showToast(
        message: 'Enter a valid email and password (min 6 chars).',
        backgroundColor: colors.errorContainer,
        foregroundColor: colors.onErrorContainer,
        icon: Icons.error_rounded,
      );
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
        final displayName = (profile?.name.isNotEmpty ?? false)
            ? profile!.name
            : email.split('@').first;
        _showToast(
          message: 'Welcome back, $displayName',
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          icon: Icons.check_circle_rounded,
        );
        Navigator.of(
          context,
        ).pushReplacementNamed(profile != null ? '/home' : '/onboarding');
        HapticsService.success();
        return;
      }

      await _authService.signUpWithEmail(email, password);
      if (!mounted) return;
      HapticsService.success();
      _showToast(
        message: 'Account created. Let\'s set up your profile.',
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        icon: Icons.verified_rounded,
      );
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } catch (e) {
      if (!mounted) return;
      HapticsService.error();
      _showToast(
        message: _friendlyError(e),
        backgroundColor: colors.errorContainer,
        foregroundColor: colors.onErrorContainer,
        icon: Icons.error_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final canSubmit = _isEmailValid && _isPasswordValid && !_isLoading;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(
                colors.primary.withValues(alpha: 0.10),
                colors.surface,
              ),
              colors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 48,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'LiftLab',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedOpacity(
                      opacity: _entered ? 1 : 0,
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      child: Text(
                        'Training. Nutrition. Recovery.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                    ),
                    const Spacer(),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 480),
                      curve: Curves.easeOutCubic,
                      offset: _entered ? Offset.zero : const Offset(0, 0.06),
                      child: AnimatedOpacity(
                        opacity: _entered ? 1 : 0,
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOut,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              colors.primary.withValues(alpha: 0.06),
                              colors.surface,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colors.onSurface.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                child: Text(
                                  _isLogin
                                      ? 'Welcome back'
                                      : 'Create your account',
                                  key: ValueKey(_isLogin),
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isLogin
                                    ? 'Log in to continue your plan.'
                                    : 'Start your personalized fitness journey.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurface.withValues(
                                    alpha: 0.72,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'you@example.com',
                                  prefixIcon: Icon(
                                    Icons.alternate_email_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) {
                                  if (canSubmit) _submit();
                                },
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Minimum 6 characters',
                                  prefixIcon: const Icon(Icons.lock_rounded),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      );
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: canSubmit
                                      ? () {
                                          HapticsService.medium();
                                          _submit();
                                        }
                                      : null,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          child: Text(
                                            _isLogin
                                                ? 'LOGIN'
                                                : 'CREATE ACCOUNT',
                                            key: ValueKey(_isLogin),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          HapticsService.selection();
                                          setState(() {
                                            _isLogin = !_isLogin;
                                          });
                                        },
                                  child: Text(
                                    _isLogin
                                        ? 'Need an account? Sign up'
                                        : 'Already have an account? Login',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
