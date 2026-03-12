import 'package:flutter/material.dart';
import 'package:lift_lab/models/user_model.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';
import 'package:lift_lab/services/haptics_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _databaseService = DatabaseService();
  final _authService = AuthService();

  int _currentPage = 0;
  bool _isLoading = false;

  String _goal = 'Hypertrophy';
  String _experience = 'Beginner (0-1 years)';
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _sleepController = TextEditingController(text: '7');
  String _activityLevel = 'Moderate';
  String _gymAccess = 'Commercial Gym';

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bodyFatController.dispose();
    _sleepController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    if (_currentPage != 2 && _currentPage != 3) {
      return true;
    }

    if (_currentPage == 2) {
      final age = int.tryParse(_ageController.text.trim());
      final height = double.tryParse(_heightController.text.trim());
      final weight = double.tryParse(_weightController.text.trim());
      final bodyFatRaw = _bodyFatController.text.trim();
      final bodyFat = bodyFatRaw.isEmpty ? null : double.tryParse(bodyFatRaw);

      if (age == null || age < 13 || age > 100) {
        _showValidationError('Enter a valid age between 13 and 100.');
        return false;
      }
      if (height == null || height < 100 || height > 250) {
        _showValidationError('Enter a valid height in cm.');
        return false;
      }
      if (weight == null || weight < 30 || weight > 300) {
        _showValidationError('Enter a valid weight in kg.');
        return false;
      }
      if (bodyFatRaw.isNotEmpty &&
          (bodyFat == null || bodyFat <= 0 || bodyFat >= 80)) {
        _showValidationError('Body fat should be between 1 and 79.');
        return false;
      }
      return true;
    }

    final sleep = double.tryParse(_sleepController.text.trim());
    if (sleep == null || sleep < 3 || sleep > 14) {
      _showValidationError('Enter average sleep between 3 and 14 hours.');
      return false;
    }
    return true;
  }

  void _showValidationError(String message) {
    HapticsService.error();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _finishOnboarding() async {
    print('DEBUG: _finishOnboarding started');
    if (!_validateCurrentStep()) {
      print('DEBUG: Validation failed');
      return;
    }

    setState(() => _isLoading = true);
    final user = _authService.currentUser;
    if (user == null) {
      print('DEBUG: User is null');
      if (mounted) {
        setState(() => _isLoading = false);
        _showValidationError('Your session expired. Please log in again.');
      }
      return;
    }

    print('DEBUG: Creating user profile for UID: ${user.uid}');
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: (user.email ?? 'Member').split('@').first,
      profileImageUrl: null,
      goal: _goal,
      experienceLevel: _experience,
      metrics: {
        'age': int.parse(_ageController.text.trim()),
        'height': double.parse(_heightController.text.trim()),
        'weight': double.parse(_weightController.text.trim()),
        'bodyFat': _bodyFatController.text.trim().isEmpty
            ? null
            : double.parse(_bodyFatController.text.trim()),
      },
      lifestyle: {
        'sleep': double.parse(_sleepController.text.trim()),
        'activityLevel': _activityLevel,
        'gymAccess': _gymAccess,
      },
    );

    try {
      print('DEBUG: Calling _databaseService.saveUserProfile (optimistic)');
      // Do not await here to provide an instant UI experience
      _databaseService.saveUserProfile(userModel).catchError((e) {
        print('DEBUG: Background save failed: $e');
      });
      
      HapticsService.success();
      print('DEBUG: Navigating to /home immediately');
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      print('DEBUG: Error in _finishOnboarding: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showValidationError(e.toString());
      }
    } finally {
      print('DEBUG: _finishOnboarding finally block');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _nextPage() async {
    if (!_validateCurrentStep()) return;

    if (_currentPage < 3) {
      HapticsService.selection();
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await _finishOnboarding();
  }

  Future<void> _previousPage() async {
    if (_currentPage == 0) return;
    HapticsService.light();
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentPage + 1) / 4;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set up your plan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Step ${_currentPage + 1} of 4',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: progress,
                      backgroundColor: colors.onSurface.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _GoalStep(
                    selectedGoal: _goal,
                    onSelect: (value) {
                      HapticsService.selection();
                      setState(() => _goal = value);
                    },
                  ),
                  _ExperienceStep(
                    selectedExperience: _experience,
                    onSelect: (value) {
                      HapticsService.selection();
                      setState(() => _experience = value);
                    },
                  ),
                  _MetricsStep(
                    ageController: _ageController,
                    heightController: _heightController,
                    weightController: _weightController,
                    bodyFatController: _bodyFatController,
                  ),
                  _LifestyleStep(
                    sleepController: _sleepController,
                    activityLevel: _activityLevel,
                    gymAccess: _gymAccess,
                    onActivityChanged: (value) {
                      if (value != null) {
                        HapticsService.selection();
                        setState(() => _activityLevel = value);
                      }
                    },
                    onGymChanged: (value) {
                      if (value != null) {
                        HapticsService.selection();
                        setState(() => _gymAccess = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: (_currentPage > 0 && !_isLoading)
                          ? () {
                              _previousPage();
                            }
                          : null,
                      child: const Text('BACK'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              HapticsService.medium();
                              _nextPage();
                            },
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_currentPage == 3 ? 'FINISH' : 'NEXT'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.selectedGoal, required this.onSelect});

  final String selectedGoal;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final options = const [
      ('Hypertrophy', Icons.fitness_center_rounded),
      ('Strength', Icons.flash_on_rounded),
      ('Fat Loss', Icons.local_fire_department_rounded),
      ('Longevity', Icons.favorite_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your primary goal?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final (label, icon) = options[index];
                final selected = selectedGoal == label;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onSelect(label),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? colors.primary
                            : colors.onSurface.withValues(alpha: 0.24),
                        width: selected ? 2 : 1,
                      ),
                      color: selected
                          ? colors.primary.withValues(alpha: 0.10)
                          : colors.onSurface.withValues(alpha: 0.03),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: colors.primary),
                        const Spacer(),
                        Text(
                          label,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceStep extends StatelessWidget {
  const _ExperienceStep({
    required this.selectedExperience,
    required this.onSelect,
  });

  final String selectedExperience;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final options = const [
      'Beginner (0-1 years)',
      'Intermediate (1-3 years)',
      'Advanced (3+ years)',
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience level',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          ...options.map((option) {
            final selected = option == selectedExperience;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton(
                onPressed: () => onSelect(option),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: selected
                      ? colors.primary.withValues(alpha: 0.10)
                      : null,
                  side: BorderSide(
                    color: selected
                        ? colors.primary
                        : colors.onSurface.withValues(alpha: 0.24),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Text(option),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MetricsStep extends StatelessWidget {
  const _MetricsStep({
    required this.ageController,
    required this.heightController,
    required this.weightController,
    required this.bodyFatController,
  });

  final TextEditingController ageController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController bodyFatController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Text('Body metrics', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _NumberField(
            controller: ageController,
            label: 'Age',
            hint: 'e.g. 25',
          ),
          const SizedBox(height: 12),
          _NumberField(
            controller: heightController,
            label: 'Height (cm)',
            hint: 'e.g. 175',
          ),
          const SizedBox(height: 12),
          _NumberField(
            controller: weightController,
            label: 'Weight (kg)',
            hint: 'e.g. 72',
          ),
          const SizedBox(height: 12),
          _NumberField(
            controller: bodyFatController,
            label: 'Body Fat % (Optional)',
            hint: 'e.g. 16',
          ),
        ],
      ),
    );
  }
}

class _LifestyleStep extends StatelessWidget {
  const _LifestyleStep({
    required this.sleepController,
    required this.activityLevel,
    required this.gymAccess,
    required this.onActivityChanged,
    required this.onGymChanged,
  });

  final TextEditingController sleepController;
  final String activityLevel;
  final String gymAccess;
  final ValueChanged<String?> onActivityChanged;
  final ValueChanged<String?> onGymChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Text('Lifestyle', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _NumberField(
            controller: sleepController,
            label: 'Average Sleep (hours)',
            hint: 'e.g. 7.5',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Activity Level'),
            initialValue: activityLevel,
            items: const [
              DropdownMenuItem(value: 'Sedentary', child: Text('Sedentary')),
              DropdownMenuItem(value: 'Light', child: Text('Lightly Active')),
              DropdownMenuItem(
                value: 'Moderate',
                child: Text('Moderately Active'),
              ),
              DropdownMenuItem(value: 'Active', child: Text('Very Active')),
            ],
            onChanged: onActivityChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Gym Access'),
            initialValue: gymAccess,
            items: const [
              DropdownMenuItem(
                value: 'Commercial Gym',
                child: Text('Commercial Gym'),
              ),
              DropdownMenuItem(value: 'Home Gym', child: Text('Home Gym')),
              DropdownMenuItem(
                value: 'Bodyweight',
                child: Text('Bodyweight Only'),
              ),
            ],
            onChanged: onGymChanged,
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
