import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
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
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: const [
                  OnboardingGoalPage(),
                  OnboardingExperiencePage(),
                  OnboardingMetricsPage(),
                  OnboardingLifestylePage(),
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
                    onPressed: _nextPage,
                    child: Text(_currentPage == 3 ? 'FINISH' : 'NEXT'),
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
  const OnboardingGoalPage({super.key});

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
              _GoalCard(icon: Icons.fitness_center, label: 'Hypertrophy'),
              _GoalCard(icon: Icons.bolt, label: 'Strength'),
              _GoalCard(icon: Icons.local_fire_department, label: 'Fat Loss'),
              _GoalCard(icon: Icons.favorite, label: 'Longevity'),
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

  const _GoalCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class OnboardingExperiencePage extends StatelessWidget {
  const OnboardingExperiencePage({super.key});

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
          _ExperienceButton(label: 'Beginner (0-1 years)'),
          const SizedBox(height: 16),
          _ExperienceButton(label: 'Intermediate (1-3 years)'),
          const SizedBox(height: 16),
          _ExperienceButton(label: 'Advanced (3+ years)'),
        ],
      ),
    );
  }
}

class _ExperienceButton extends StatelessWidget {
  final String label;

  const _ExperienceButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}

class OnboardingMetricsPage extends StatelessWidget {
  const OnboardingMetricsPage({super.key});

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
          const TextField(decoration: InputDecoration(labelText: 'Age')),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'Height (cm)')),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'Weight (kg)')),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'Body Fat % (Optional)')),
        ],
      ),
    );
  }
}

class OnboardingLifestylePage extends StatelessWidget {
  const OnboardingLifestylePage({super.key});

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
           const TextField(decoration: InputDecoration(labelText: 'Average Sleep (hours)')),
           const SizedBox(height: 16),
           DropdownButtonFormField<String>(
             decoration: const InputDecoration(labelText: 'Activity Level'),
             items: const [
               DropdownMenuItem(value: 'Sedentary', child: Text('Sedentary')),
               DropdownMenuItem(value: 'Light', child: Text('Lightly Active')),
               DropdownMenuItem(value: 'Moderate', child: Text('Moderately Active')),
               DropdownMenuItem(value: 'Active', child: Text('Very Active')),
             ],
             onChanged: (value) {},
           ),
           const SizedBox(height: 16),
           DropdownButtonFormField<String>(
             decoration: const InputDecoration(labelText: 'Gym Access'),
             items: const [
               DropdownMenuItem(value: 'Commercial Gym', child: Text('Commercial Gym')),
               DropdownMenuItem(value: 'Home Gym', child: Text('Home Gym')),
               DropdownMenuItem(value: 'Bodyweight', child: Text('Bodyweight Only')),
             ],
             onChanged: (value) {},
           ),
        ],
      ),
    );
  }
}
