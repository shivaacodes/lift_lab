import 'package:flutter/material.dart';
import 'package:lift_lab/models/user_model.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  
  int _currentPage = 0;
  bool _isLoading = false;

  // Data
  String _goal = 'Hypertrophy';
  String _experience = 'Beginner (0-1 years)';
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _sleepController = TextEditingController();
  String _activityLevel = 'Moderate';
  String _gymAccess = 'Commercial Gym';

  Future<void> _finishOnboarding() async {
    setState(() => _isLoading = true);
    final user = _authService.currentUser;
    
    // Mock Mode or Unauthenticated
    if (user == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
      return;
    }

    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      goal: _goal,
      experienceLevel: _experience,
      metrics: {
        'age': int.tryParse(_ageController.text) ?? 0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'bodyFat': double.tryParse(_bodyFatController.text),
      },
      lifestyle: {
        'sleep': double.tryParse(_sleepController.text) ?? 7.0,
        'activityLevel': _activityLevel,
        'gymAccess': _gymAccess,
      },
    );

    try {
      await _databaseService.saveUserProfile(userModel);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Prevent swiping to force validation
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  OnboardingGoalPage(
                    selectedGoal: _goal,
                    onSelect: (val) => setState(() => _goal = val),
                  ),
                  OnboardingExperiencePage(
                    selectedExperience: _experience,
                    onSelect: (val) => setState(() => _experience = val),
                  ),
                  OnboardingMetricsPage(
                    ageController: _ageController,
                    heightController: _heightController,
                    weightController: _weightController,
                    bodyFatController: _bodyFatController,
                  ),
                  OnboardingLifestylePage(
                    sleepController: _sleepController,
                    activityLevel: _activityLevel,
                    gymAccess: _gymAccess,
                    onActivityChanged: (val) => setState(() => _activityLevel = val!),
                    onGymChanged: (val) => setState(() => _gymAccess = val!),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   // Page indicator
                  Row(
                    children: List.generate(
                      4,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _nextPage,
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : Text(_currentPage == 3 ? 'FINISH' : 'NEXT'),
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

class OnboardingGoalPage extends StatelessWidget {
  final String selectedGoal;
  final Function(String) onSelect;

  const OnboardingGoalPage({super.key, required this.selectedGoal, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'What is your primary goal?',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _GoalCard(
                icon: Icons.fitness_center, 
                label: 'Hypertrophy', 
                isSelected: selectedGoal == 'Hypertrophy', 
                onTap: () => onSelect('Hypertrophy'),
              ),
              _GoalCard(
                icon: Icons.bolt, 
                label: 'Strength', 
                isSelected: selectedGoal == 'Strength', 
                onTap: () => onSelect('Strength'),
              ),
              _GoalCard(
                icon: Icons.local_fire_department, 
                label: 'Fat Loss', 
                isSelected: selectedGoal == 'Fat Loss', 
                onTap: () => onSelect('Fat Loss'),
              ),
              _GoalCard(
                icon: Icons.favorite, 
                label: 'Longevity', 
                isSelected: selectedGoal == 'Longevity', 
                onTap: () => onSelect('Longevity'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.icon, 
    required this.label, 
    required this.isSelected, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.2) : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.white10,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              size: 48, 
              color: isSelected ? theme.colorScheme.primary : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              label, 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey,
              )
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingExperiencePage extends StatelessWidget {
  final String selectedExperience;
  final Function(String) onSelect;

  const OnboardingExperiencePage({super.key, required this.selectedExperience, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Experience Level',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _ExperienceButton(
            label: 'Beginner (0-1 years)', 
            isSelected: selectedExperience == 'Beginner (0-1 years)',
            onTap: () => onSelect('Beginner (0-1 years)'),
          ),
          const SizedBox(height: 16),
          _ExperienceButton(
            label: 'Intermediate (1-3 years)', 
            isSelected: selectedExperience == 'Intermediate (1-3 years)',
            onTap: () => onSelect('Intermediate (1-3 years)'),
          ),
          const SizedBox(height: 16),
          _ExperienceButton(
            label: 'Advanced (3+ years)', 
            isSelected: selectedExperience == 'Advanced (3+ years)',
            onTap: () => onSelect('Advanced (3+ years)'),
          ),
        ],
      ),
    );
  }
}

class _ExperienceButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExperienceButton({
    required this.label, 
    required this.isSelected, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : null,
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70, 
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          )
        ),
      ),
    );
  }
}

class OnboardingMetricsPage extends StatelessWidget {
  final TextEditingController ageController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController bodyFatController;

  const OnboardingMetricsPage({
    super.key,
    required this.ageController,
    required this.heightController,
    required this.weightController,
    required this.bodyFatController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Body Metrics',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(controller: ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age')),
          const SizedBox(height: 16),
          TextField(controller: heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height (cm)')),
          const SizedBox(height: 16),
          TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)')),
          const SizedBox(height: 16),
          TextField(controller: bodyFatController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Body Fat % (Optional)')),
        ],
      ),
    );
  }
}

class OnboardingLifestylePage extends StatelessWidget {
  final TextEditingController sleepController;
  final String activityLevel;
  final String gymAccess;
  final Function(String?) onActivityChanged;
  final Function(String?) onGymChanged;

  const OnboardingLifestylePage({
    super.key,
    required this.sleepController,
    required this.activityLevel,
    required this.gymAccess,
    required this.onActivityChanged,
    required this.onGymChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Lifestyle Checklist',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
           TextField(controller: sleepController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Average Sleep (hours)')),
           const SizedBox(height: 16),
           DropdownButtonFormField<String>(
             decoration: const InputDecoration(labelText: 'Activity Level'),
             value: activityLevel,
             items: const [
               DropdownMenuItem(value: 'Sedentary', child: Text('Sedentary')),
               DropdownMenuItem(value: 'Light', child: Text('Lightly Active')),
               DropdownMenuItem(value: 'Moderate', child: Text('Moderately Active')),
               DropdownMenuItem(value: 'Active', child: Text('Very Active')),
             ],
             onChanged: onActivityChanged,
           ),
           const SizedBox(height: 16),
           DropdownButtonFormField<String>(
             decoration: const InputDecoration(labelText: 'Gym Access'),
             value: gymAccess,
             items: const [
               DropdownMenuItem(value: 'Commercial Gym', child: Text('Commercial Gym')),
               DropdownMenuItem(value: 'Home Gym', child: Text('Home Gym')),
               DropdownMenuItem(value: 'Bodyweight', child: Text('Bodyweight Only')),
             ],
             onChanged: onGymChanged,
           ),
        ],
      ),
    );
  }
}

