import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lift_lab/models/user_model.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';
import 'package:lift_lab/services/storage_service.dart';
import 'package:lift_lab/services/groq_protocol_service.dart';
import 'package:lift_lab/services/haptics_service.dart';
import 'package:lift_lab/widgets/app_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _databaseService = DatabaseService();
  final _authService = AuthService();
  final _storageService = StorageService();
  final _picker = ImagePicker();

  int _currentPage = 0;
  bool _isLoading = false;
  bool _isUploading = false;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  String? _profileImageUrl;
  String _goal = 'Hypertrophy';

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    if (user != null) {
      _nameController.text = (user.email ?? 'Member').split('@').first;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
    );

    if (image == null) return;

    setState(() => _isUploading = true);
    HapticsService.light();

    try {
      final url = await _storageService.uploadProfileImage(File(image.path));
      setState(() {
        _profileImageUrl = url;
        _isUploading = false;
      });
      HapticsService.success();
    } catch (e) {
      setState(() => _isUploading = false);
      HapticsService.error();
      showBottomToast(context, 'Upload failed: $e');
    }
  }

  bool _validateCurrentStep() {
    if (_currentPage == 0) {
      if (_nameController.text.trim().isEmpty) { _showValidationError('Please enter your name'); return false; }
      return true;
    }
    if (_currentPage == 2) {
      final age = int.tryParse(_ageController.text.trim());
      if (age == null || age < 13 || age > 100) { _showValidationError('Valid age 13-100'); return false; }
      return true;
    }
    return true;
  }

  void _showValidationError(String message) {
    HapticsService.error();
    if (mounted) showBottomToast(context, message, isError: true);
  }

  Future<void> _finishOnboarding() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);
    final user = _authService.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      _showValidationError('Session expired. Please log in.');
      return;
    }

    final tempModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: _nameController.text.trim(),
      profileImageUrl: _profileImageUrl,
      goal: _goal,
      experienceLevel: 'Beginner', // Defaulted for speed
      metrics: {
        'age': int.parse(_ageController.text.trim()),
        'gender': _gender,
        'height': _gender == 'Male' ? 175.0 : 162.0, // Sensible defaults
        'weight': _gender == 'Male' ? 75.0 : 60.0,
        'bodyFat': null,
      },
      lifestyle: {
        'sleep': 7.0, // Defaulted for speed
        'activityLevel': 'Moderate',
        'gymAccess': 'Commercial Gym',
      },
    );

    try {
      if (mounted) showBottomToast(context, '🔬 Lab Analysis in progress...');
      HapticsService.medium();
      
      // Generate AI Protocol - 5s max
      final protocol = await GroqProtocolService.generateProtocol(tempModel);
      
      final finalModel = UserModel(
        uid: tempModel.uid,
        email: tempModel.email,
        name: tempModel.name,
        profileImageUrl: tempModel.profileImageUrl,
        goal: tempModel.goal,
        experienceLevel: tempModel.experienceLevel,
        metrics: tempModel.metrics,
        lifestyle: tempModel.lifestyle,
        protocol: protocol,
      );

      // Optimistic Show: Don't wait for DB save to show the results
      setState(() => _isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showProtocolSummaryModal(protocol);
      });

      // Background Save (with short timeout safety)
      try {
        await _databaseService.saveUserProfile(finalModel).timeout(const Duration(seconds: 4));
        HapticsService.success();
      } catch (e) {
        debugPrint('Optimistic Save Background Error: $e');
      }
    } catch (e) {
      debugPrint('Onboarding Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showValidationError('Protocol error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showProtocolSummaryModal(Map<String, dynamic> protocol) {
    final theme = Theme.of(context);
    final nutrition = Map<String, dynamic>.from(protocol['nutrition'] ?? {});
    final workout = Map<String, dynamic>.from(protocol['workout'] ?? {});
    final weeklyPlan = List<Map<String, dynamic>>.from(workout['weekly_plan'] ?? []);
    
    final todayIndex = DateTime.now().weekday;
    final todayWorkout = weeklyPlan.firstWhere(
      (d) => (d['day'] as num?)?.toInt() == todayIndex,
      orElse: () => {'label': 'Rest Day', 'exercises': []},
    );
    final exercises = List<Map<String, dynamic>>.from(todayWorkout['exercises'] ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LAB ANALYSIS COMPLETE', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Your Precision Protocol', style: theme.textTheme.displaySmall?.copyWith(fontSize: 32, letterSpacing: -1.0)),
            const SizedBox(height: 32),
            
            Text('DAILY NUTRITION TARGETS', style: theme.textTheme.labelMedium?.copyWith(color: Colors.black38, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x0D000000)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryMacro('Calories', '${nutrition['calories']}', '🔥'),
                  _buildSummaryMacro('Protein', '${nutrition['protein']}g', '🥩'),
                  _buildSummaryMacro('Carbs', '${nutrition['carbs']}g', '🍚'),
                  _buildSummaryMacro('Fats', '${nutrition['fats']}g', '🥑'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text('TODAY\'S TRAINING: ${todayWorkout['label']?.toString().toUpperCase()}', style: theme.textTheme.labelMedium?.copyWith(color: Colors.black38, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Expanded(
              child: exercises.isEmpty 
                ? Center(child: Text('Rest Day — Prioritize Recovery', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black45, fontWeight: FontWeight.w600)))
                : ListView.separated(
                    itemCount: (exercises.length > 4 ? 4 : exercises.length),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final ex = exercises[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x0D000000)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Center(child: Text('${i + 1}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.w800)),
                                  Text('${ex['sets']} sets × ${ex['reps']} reps', style: const TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const Icon(Icons.bolt_rounded, color: Colors.orange, size: 20),
                          ],
                        ),
                      );
                    },
                  ),
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  HapticsService.medium();
                  if (mounted) showBottomToast(context, '🚀 Welcome to the Lab — Let\'s get to work!', isSuccess: true);
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('START MY JOURNEY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMacro(String label, String value, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black26)),
      ],
    );
  }

  Future<void> _nextPage() async {
    if (!_validateCurrentStep()) return;
    if (_currentPage < 2) {
      HapticsService.selection();
      await _pageController.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
      return;
    }
    await _finishOnboarding();
  }

  Future<void> _previousPage() async {
    if (_currentPage == 0) return;
    HapticsService.light();
    await _pageController.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = (_currentPage + 1) / 3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Set up your lab',
                          style: theme.textTheme.headlineSmall?.copyWith(fontSize: 26),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Step ${_currentPage + 1} of 3',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.primary, 
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: progress,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation(colors.primary),
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
                  _IdentityStep(
                    nameController: _nameController, 
                    profileImageUrl: _profileImageUrl, 
                    isUploading: _isUploading, 
                    onPickImage: _pickImage,
                  ),
                  _GoalStep(selectedGoal: _goal, onSelect: (v) { HapticsService.selection(); setState(() => _goal = v); }),
                  _MetricsStep(
                    age: _ageController, 
                    selectedGender: _gender, 
                    onGenderSelect: (v) { HapticsService.selection(); setState(() => _gender = v); }
                  ),
                ],
              ),
            ),

            // Footer Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: _isLoading || _isUploading ? null : _previousPage,
                        child: const Text('BACK'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                     flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading || _isUploading ? null : _nextPage,
                      child: _isLoading 
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                          : Text(_currentPage == 2 ? 'BUILD MY PLAN' : 'CONTINUE'),
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

class _IdentityStep extends StatelessWidget {
  const _IdentityStep({
    required this.nameController, 
    this.profileImageUrl, 
    required this.isUploading, 
    required this.onPickImage
  });
  
  final TextEditingController nameController;
  final String? profileImageUrl;
  final bool isUploading;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = nameController.text.trim().isNotEmpty ? nameController.text.trim()[0].toUpperCase() : 'U';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Who are you?', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Let\'s personalize your profile.', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
        const SizedBox(height: 48),
        Center(
          child: GestureDetector(
            onTap: isUploading ? null : onPickImage,
            child: Stack(
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    image: (profileImageUrl != null && profileImageUrl!.isNotEmpty) 
                        ? DecorationImage(image: NetworkImage(profileImageUrl!), fit: BoxFit.cover) 
                        : null,
                  ),
                  child: (profileImageUrl == null || profileImageUrl!.isEmpty) 
                      ? Center(child: Text(initial, style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: theme.colorScheme.primary))) 
                      : null,
                ),
                if (isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 4)),
                    ),
                  ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.add_a_photo_rounded, size: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 48),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'YOUR NAME', hintText: 'e.g. John Doe'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.selectedGoal, required this.onSelect});
  final String selectedGoal;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = const [
      ('Hypertrophy', Icons.fitness_center_rounded, 'Building muscle mass'),
      ('Strength', Icons.flash_on_rounded, 'Lifting heavier loads'),
      ('Fat Loss', Icons.local_fire_department_rounded, 'Lean physique focus'),
      ('Longevity', Icons.favorite_rounded, 'General health & fitness'),
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('What is your primary goal?', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('We will tailor your volume and intensity based on this.', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 28),
        ...options.map((opt) {
          final isSelected = selectedGoal == opt.$1;
          return _SelectionCard(
            isSelected: isSelected,
            onTap: () => onSelect(opt.$1),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(opt.$2, color: isSelected ? Colors.white : Colors.black45, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt.$1, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                      Text(opt.$3, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black38)),
                    ],
                  ),
                ),
                if (isSelected) Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _MetricsStep extends StatelessWidget {
  const _MetricsStep({required this.age, required this.selectedGender, required this.onGenderSelect});
  final TextEditingController age;
  final String selectedGender;
  final ValueChanged<String> onGenderSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Biological Context', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Used for metabolic accuracy.', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        TextField(
          controller: age, 
          keyboardType: TextInputType.number, 
          decoration: const InputDecoration(
            labelText: 'AGE', 
            hintText: 'e.g. 24',
            prefixIcon: Icon(Icons.cake_outlined),
          )
        ),
        const SizedBox(height: 32),
        Text('GENDER', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.black38, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _GenderCard(
                label: 'Male',
                isSelected: selectedGender == 'Male',
                onTap: () => onGenderSelect('Male'),
                emoji: '♂️',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GenderCard(
                label: 'Female',
                isSelected: selectedGender == 'Female',
                onTap: () => onGenderSelect('Female'),
                emoji: '♀️',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({required this.label, required this.isSelected, required this.onTap, required this.emoji});
  final String label, emoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isSelected ? theme.colorScheme.primary : Colors.black45,
            )),
          ],
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({required this.isSelected, required this.onTap, required this.child});
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : const Color(0x0D000000),
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
