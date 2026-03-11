import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lift_lab/models/user_model.dart';
import 'package:lift_lab/services/ai_coach_service.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';
import 'package:lift_lab/services/haptics_service.dart';
import 'package:lift_lab/services/theme_service.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final _auth = AuthService();
  final _db = DatabaseService();
  UserModel? _navProfile;

  @override
  void initState() {
    super.initState();
    _refreshNavProfile();
  }

  Future<void> _refreshNavProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final profile = await _db.getUserProfile(user.uid);
    if (!mounted) return;
    setState(() => _navProfile = profile);
  }

  void _onItemTapped(int index) {
    HapticsService.selection();
    setState(() => _currentIndex = index);
  }

  void _openAiCoach() {
    const tips = [
      'AI: Hit the quick actions and maintain your streak.',
      'AI: Prioritize compound moves first for quality volume.',
      'AI: Keep protein spread across 3-4 meals today.',
      'AI: Review trends, then adjust one habit for next week.',
      'AI: Update your profile details weekly as your goals evolve.',
    ];
    HapticsService.medium();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Coach',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tips[_currentIndex],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = _currentIndex == index;
    final colors = Theme.of(context).colorScheme;
    final accent = _navAccent(index, colors);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: isActive ? 1.06 : 1.0,
              child: Icon(
                icon,
                size: 26,
                color: isActive
                    ? accent
                    : colors.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.25,
                color: isActive
                    ? accent
                    : colors.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNavItem() {
    final bool isActive = _currentIndex == 4;
    final colors = Theme.of(context).colorScheme;
    final accent = _navAccent(4, colors);
    final user = _auth.currentUser;
    final imageUrl = _navProfile?.profileImageUrl;
    final name = _navProfile?.name ?? (user?.email ?? 'user');
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _onItemTapped(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: isActive ? 1.06 : 1.0,
              child: CircleAvatar(
                radius: 12.5,
                backgroundColor: isActive
                    ? accent.withValues(alpha: 0.22)
                    : colors.onSurface.withValues(alpha: 0.10),
                backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                    ? NetworkImage(imageUrl)
                    : null,
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? Text(
                        initial,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? accent
                              : colors.onSurface.withValues(alpha: 0.7),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.25,
                color: isActive
                    ? accent
                    : colors.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
              child: const Text('Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pages = [
      HomeTab(
        onOpenTrain: () => _onItemTapped(1),
        onOpenNutrition: () => _onItemTapped(2),
      ),
      const TrainTab(),
      const NutritionTab(),
      const HistoryTab(),
      ProfileTab(onProfileUpdated: _refreshNavProfile),
    ];

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: colors.surface,
      body: IndexedStack(index: _currentIndex, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAiCoach,
        backgroundColor: Color.alphaBlend(
          colors.primary.withValues(alpha: 0.22),
          colors.surface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.primary.withValues(alpha: 0.35)),
        ),
        child: Icon(Icons.smart_toy_rounded, color: colors.primary, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(
                  colors.primary.withValues(alpha: 0.10),
                  colors.surface,
                ),
                Color.alphaBlend(
                  colors.secondary.withValues(alpha: 0.08),
                  colors.surface,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.onSurface.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.space_dashboard_rounded,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.sports_gymnastics_rounded,
                label: 'Train',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.dining_rounded,
                label: 'Nutrition',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.insights_rounded,
                label: 'History',
              ),
              _buildProfileNavItem(),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.onOpenTrain,
    required this.onOpenNutrition,
  });

  final VoidCallback onOpenTrain;
  final VoidCallback onOpenNutrition;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _auth = AuthService();
  final _db = DatabaseService();
  late Future<_HomeData> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _load();
  }

  Future<void> _refresh() async {
    setState(() => _homeFuture = _load());
    await _homeFuture;
  }

  Future<_HomeData> _load() async {
    final uid = _auth.currentUser!.uid;
    final profile = await _db.getUserProfile(uid);
    final workouts = await _db.getRecentWorkoutLogs(uid, limit: 8);
    final nutrition = await _db.getTodayNutritionLogs(uid);
    return _HomeData(
      profile: profile,
      workouts: workouts,
      todayNutrition: nutrition,
    );
  }

  int _workoutStreakDays(List<Map<String, dynamic>> workouts) {
    if (workouts.isEmpty) return 0;
    final uniqueDates = <String>{};
    for (final w in workouts) {
      final d = _toDate(w['createdAt']);
      if (d == null) continue;
      uniqueDates.add('${d.year}-${d.month}-${d.day}');
    }
    return uniqueDates.length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeData>(
      future: _homeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data;
        if (data == null) return const Center(child: Text('No data'));

        final name = (data.profile?.name.isNotEmpty ?? false)
            ? data.profile!.name
            : (_auth.currentUser?.email ?? 'Member').split('@').first;
        final weight =
            (data.profile?.metrics['weight'] as num?)?.toDouble() ?? 70;
        final calorieTarget = (weight * 33).round();
        final proteinTarget = (weight * 2.2).round();
        final caloriesToday = data.todayNutrition.fold<int>(
          0,
          (total, item) => total + ((item['calories'] ?? 0) as num).toInt(),
        );
        final proteinToday = data.todayNutrition.fold<int>(
          0,
          (total, item) => total + ((item['protein'] ?? 0) as num).toInt(),
        );
        final streak = _workoutStreakDays(data.workouts);
        final latestWorkout = data.workouts.isNotEmpty
            ? data.workouts.first
            : null;
        final latestMeal = data.todayNutrition.isNotEmpty
            ? data.todayNutrition.first
            : null;

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 18),
                _InfoCard(
                  title: 'Today Snapshot',
                  order: 0,
                  child: Row(
                    children: [
                      _MetricBlock(
                        label: 'Goal',
                        value: data.profile?.goal ?? 'N/A',
                      ),
                      _MetricBlock(label: 'Streak', value: '$streak days'),
                      _MetricBlock(
                        label: 'Protein',
                        value: '$proteinToday/$proteinTarget g',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Quick Actions',
                  order: 1,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _ActionPill(
                        icon: Icons.fitness_center_rounded,
                        text: 'Open Train',
                        onTap: widget.onOpenTrain,
                      ),
                      _ActionPill(
                        icon: Icons.dining_rounded,
                        text: 'Open Nutrition',
                        onTap: widget.onOpenNutrition,
                      ),
                      _ActionPill(
                        icon: Icons.tips_and_updates_rounded,
                        text: 'AI Tip',
                        onTap: () => _showBottomToast(
                          context,
                          AiCoachService.weeklyInsight(
                            workouts: streak,
                            avgProtein: proteinToday,
                            proteinTarget: proteinTarget,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Nutrition Today',
                  order: 2,
                  child: Column(
                    children: [
                      _MacroRow(
                        label: 'Calories',
                        current: caloriesToday,
                        target: calorieTarget,
                      ),
                      _MacroRow(
                        label: 'Protein',
                        current: proteinToday,
                        target: proteinTarget,
                      ),
                      if (latestMeal != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Latest meal: ${latestMeal['mealName'] ?? 'Meal'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Recent Sessions',
                  order: 3,
                  child: latestWorkout == null
                      ? const Text('No workouts logged yet.')
                      : ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            latestWorkout['sessionName'] ?? 'Session',
                          ),
                          subtitle: Text(
                            '${latestWorkout['completedSets'] ?? 0} sets • ${_fmtDate(_toDate(latestWorkout['createdAt']))}',
                          ),
                          trailing: TextButton(
                            onPressed: widget.onOpenTrain,
                            child: const Text('Continue'),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TrainTab extends StatefulWidget {
  const TrainTab({super.key});

  @override
  State<TrainTab> createState() => _TrainTabState();
}

class _TrainTabState extends State<TrainTab> {
  final _auth = AuthService();
  final _db = DatabaseService();

  UserModel? _profile;
  bool _loading = true;
  bool _saving = false;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  int _elapsedSeconds = 0;

  final List<Map<String, dynamic>> _session = [
    {'name': 'Bench Press', 'sets': 4, 'reps': '6-8', 'done': 0},
    {'name': 'Row', 'sets': 3, 'reps': '8-10', 'done': 0},
    {'name': 'Squat', 'sets': 4, 'reps': '5-6', 'done': 0},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final profile = await _db.getUserProfile(user.uid);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  void _toggleTimer() {
    HapticsService.selection();
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _ticker?.cancel();
    } else {
      _stopwatch.start();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _elapsedSeconds = _stopwatch.elapsed.inSeconds);
      });
    }
    setState(() {});
  }

  Future<void> _saveSession() async {
    final user = _auth.currentUser;
    if (user == null) return;
    setState(() => _saving = true);

    final completedSets = _session.fold<int>(
      0,
      (total, item) => total + (item['done'] as int),
    );
    final durationMinutes = (_elapsedSeconds / 60).ceil();

    try {
      await _db.logWorkoutSession(
        user.uid,
        sessionName: '${_profile?.goal ?? 'Training'} Session',
        durationMinutes: durationMinutes == 0 ? 1 : durationMinutes,
        completedSets: completedSets,
        exercises: _session,
      );
      HapticsService.success();
      if (!mounted) return;
      _showBottomToast(context, 'Workout session saved');
    } catch (e) {
      HapticsService.error();
      if (!mounted) return;
      _showBottomToast(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('Training', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Goal: ${_profile?.goal ?? 'General Fitness'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Session Controls',
            order: 0,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleTimer,
                    icon: Icon(
                      _stopwatch.isRunning
                          ? Icons.pause_circle_rounded
                          : Icons.play_circle_rounded,
                    ),
                    label: Text(_stopwatch.isRunning ? 'Pause' : 'Start'),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _fmtDuration(_elapsedSeconds),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InfoCard(
            title: 'Today Plan',
            order: 1,
            child: Column(
              children: _session.map((item) {
                final int sets = item['sets'] as int;
                final int done = item['done'] as int;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item['name'] as String),
                  subtitle: Text('$sets sets • ${item['reps']} reps'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: done > 0
                            ? () {
                                HapticsService.light();
                                setState(() => item['done'] = done - 1);
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_rounded),
                      ),
                      Text('$done/$sets'),
                      IconButton(
                        onPressed: done < sets
                            ? () {
                                HapticsService.selection();
                                setState(() => item['done'] = done + 1);
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_rounded),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          _InfoCard(
            title: 'AI Exercise Swap',
            order: 2,
            child: Builder(
              builder: (context) {
                final first = _session.first;
                final suggestion = AiCoachService.workoutSwapSuggestion(
                  goal: _profile?.goal ?? 'Hypertrophy',
                  exercise: first['name'] as String,
                  gymAccess:
                      (_profile?.lifestyle['gymAccess'] ?? 'Commercial Gym')
                          .toString(),
                );
                return Text('For ${first['name']}: $suggestion');
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saving ? null : _saveSession,
            icon: _saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.task_alt_rounded),
            label: const Text('Save Session'),
          ),
        ],
      ),
    );
  }
}

class NutritionTab extends StatefulWidget {
  const NutritionTab({super.key});

  @override
  State<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab> {
  final _auth = AuthService();
  final _db = DatabaseService();

  final _mealCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();

  UserModel? _profile;
  List<Map<String, dynamic>> _today = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _mealCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final profile = await _db.getUserProfile(user.uid);
    final today = await _db.getTodayNutritionLogs(user.uid);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _today = today;
      _loading = false;
    });
  }

  Future<void> _addMeal() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final name = _mealCtrl.text.trim();
    final calories = int.tryParse(_calCtrl.text.trim());
    final protein = int.tryParse(_proteinCtrl.text.trim());
    final carbs = int.tryParse(_carbCtrl.text.trim());
    final fats = int.tryParse(_fatCtrl.text.trim());
    if (name.isEmpty ||
        calories == null ||
        protein == null ||
        carbs == null ||
        fats == null) {
      HapticsService.error();
      _showBottomToast(context, 'Fill all meal fields with valid numbers.');
      return;
    }

    setState(() => _saving = true);
    try {
      await _db.logNutritionEntry(
        user.uid,
        mealName: name,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
      );
      HapticsService.success();
      _mealCtrl.clear();
      _calCtrl.clear();
      _proteinCtrl.clear();
      _carbCtrl.clear();
      _fatCtrl.clear();
      await _load();
      if (!mounted) return;
      _showBottomToast(context, 'Meal logged');
    } catch (e) {
      HapticsService.error();
      if (!mounted) return;
      _showBottomToast(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Map<String, int> _macroTargets(UserModel? profile) {
    final weight = ((profile?.metrics['weight'] ?? 70) as num).toDouble();
    final goal = (profile?.goal ?? 'Hypertrophy').toLowerCase();

    final int calories;
    final int protein = (weight * 2.2).round();
    final int carbs;
    final int fats;

    if (goal.contains('fat')) {
      calories = (weight * 29).round();
      carbs = (weight * 2.5).round();
      fats = (weight * 0.8).round();
    } else if (goal.contains('strength')) {
      calories = (weight * 35).round();
      carbs = (weight * 4).round();
      fats = (weight * 1).round();
    } else if (goal.contains('longevity')) {
      calories = (weight * 31).round();
      carbs = (weight * 3).round();
      fats = (weight * 0.9).round();
    } else {
      calories = (weight * 33).round();
      carbs = (weight * 3.5).round();
      fats = (weight * 0.9).round();
    }

    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final targets = _macroTargets(_profile);
    final targetCalories = targets['calories']!;
    final targetProtein = targets['protein']!;
    final targetCarbs = targets['carbs']!;
    final targetFats = targets['fats']!;

    final cals = _today.fold<int>(
      0,
      (s, e) => s + ((e['calories'] ?? 0) as num).toInt(),
    );
    final protein = _today.fold<int>(
      0,
      (s, e) => s + ((e['protein'] ?? 0) as num).toInt(),
    );
    final carbs = _today.fold<int>(
      0,
      (s, e) => s + ((e['carbs'] ?? 0) as num).toInt(),
    );
    final fats = _today.fold<int>(
      0,
      (s, e) => s + ((e['fats'] ?? 0) as num).toInt(),
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Text('Nutrition', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Goal mode: ${_profile?.goal ?? 'Hypertrophy'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          _InfoCard(
            title: 'Macro Progress',
            order: 0,
            child: Column(
              children: [
                _MacroRow(
                  label: 'Calories',
                  current: cals,
                  target: targetCalories,
                ),
                _MacroRow(
                  label: 'Protein',
                  current: protein,
                  target: targetProtein,
                ),
                _MacroRow(label: 'Carbs', current: carbs, target: targetCarbs),
                _MacroRow(label: 'Fats', current: fats, target: targetFats),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Remaining: '
                    '${(targetCalories - cals).clamp(0, targetCalories)} kcal, '
                    'P ${(targetProtein - protein).clamp(0, targetProtein)}g, '
                    'C ${(targetCarbs - carbs).clamp(0, targetCarbs)}g, '
                    'F ${(targetFats - fats).clamp(0, targetFats)}g',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InfoCard(
            title: 'Add Meal',
            order: 1,
            child: Column(
              children: [
                TextField(
                  controller: _mealCtrl,
                  decoration: const InputDecoration(labelText: 'Meal name'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _calCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'kcal'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _proteinCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Protein'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _carbCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Carbs'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _fatCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Fats'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _addMeal,
                  icon: const Icon(Icons.add_circle_rounded),
                  label: const Text('Log Meal'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InfoCard(
            title: 'AI Meal Suggestion',
            order: 2,
            child: Text(
              AiCoachService.mealSuggestion(
                remainingCalories: (targetCalories - cals).clamp(
                  0,
                  targetCalories,
                ),
                remainingProtein: (targetProtein - protein).clamp(
                  0,
                  targetProtein,
                ),
                remainingCarbs: (targetCarbs - carbs).clamp(0, targetCarbs),
                remainingFats: (targetFats - fats).clamp(0, targetFats),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _InfoCard(
            title: 'Today Entries',
            order: 3,
            child: _today.isEmpty
                ? const Text('No meals logged today.')
                : Column(
                    children: _today.map((entry) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(entry['mealName']?.toString() ?? 'Meal'),
                        subtitle: Text(
                          '${entry['calories']} kcal • P ${entry['protein']} C ${entry['carbs']} F ${entry['fats']}',
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final _auth = AuthService();
  final _db = DatabaseService();
  late Future<_HistoryData> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _load();
  }

  Future<void> _refresh() async {
    setState(() => _historyFuture = _load());
    await _historyFuture;
  }

  Future<_HistoryData> _load() async {
    final uid = _auth.currentUser!.uid;
    final workouts = await _db.getRecentWorkoutLogs(uid, limit: 20);
    final nutrition = await _db.getRecentNutritionLogs(uid, limit: 60);
    final profile = await _db.getUserProfile(uid);
    return _HistoryData(
      workouts: workouts,
      nutrition: nutrition,
      profile: profile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HistoryData>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data;
        if (data == null) return const Center(child: Text('No history yet.'));

        final weekStart = DateTime.now().subtract(const Duration(days: 7));
        final workoutsThisWeek = data.workouts.where((w) {
          final date = _toDate(w['createdAt']);
          return date != null && date.isAfter(weekStart);
        }).length;

        final nutritionWeek = data.nutrition.where((n) {
          final date = _toDate(n['createdAt']);
          return date != null && date.isAfter(weekStart);
        }).toList();

        int avgProtein = 0;
        if (nutritionWeek.isNotEmpty) {
          final proteinSum = nutritionWeek.fold<int>(
            0,
            (total, entry) => total + ((entry['protein'] ?? 0) as num).toInt(),
          );
          avgProtein = (proteinSum / 7).round();
        }

        final weight = ((data.profile?.metrics['weight'] ?? 70) as num)
            .toDouble();
        final proteinTarget = (weight * 2.2).round();

        final insight = AiCoachService.weeklyInsight(
          workouts: workoutsThisWeek,
          avgProtein: avgProtein,
          proteinTarget: proteinTarget,
        );

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text('History', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Weekly Summary',
                  order: 0,
                  child: Row(
                    children: [
                      _MetricBlock(
                        label: 'Workouts',
                        value: '$workoutsThisWeek',
                      ),
                      _MetricBlock(
                        label: 'Avg Protein',
                        value: '$avgProtein g',
                      ),
                      _MetricBlock(label: 'Target', value: '$proteinTarget g'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'AI Weekly Insight',
                  order: 1,
                  child: Text(insight),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Recent Workouts',
                  order: 2,
                  child: data.workouts.isEmpty
                      ? const Text('No workouts logged yet.')
                      : Column(
                          children: data.workouts.take(6).map((entry) {
                            final date = _toDate(entry['createdAt']);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                entry['sessionName']?.toString() ?? 'Workout',
                              ),
                              subtitle: Text(
                                '${entry['completedSets'] ?? 0} sets • ${_fmtDate(date)}',
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Recent Meals',
                  order: 3,
                  child: data.nutrition.isEmpty
                      ? const Text('No meal history yet.')
                      : Column(
                          children: data.nutrition.take(6).map((entry) {
                            final date = _toDate(entry['createdAt']);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                entry['mealName']?.toString() ?? 'Meal',
                              ),
                              subtitle: Text(
                                '${entry['calories']} kcal • ${_fmtDate(date)}',
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.onProfileUpdated});
  final Future<void> Function() onProfileUpdated;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _auth = AuthService();
  final _db = DatabaseService();

  final _nameCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _sleepCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _imageCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _sleepCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final profile = await _db.getUserProfile(user.uid);
    if (!mounted) return;

    _nameCtrl.text = (profile?.name.isNotEmpty ?? false)
        ? profile!.name
        : (user.email ?? 'Member').split('@').first;
    _imageCtrl.text = profile?.profileImageUrl ?? '';
    _ageCtrl.text = '${profile?.metrics['age'] ?? ''}';
    _heightCtrl.text = '${profile?.metrics['height'] ?? ''}';
    _weightCtrl.text = '${profile?.metrics['weight'] ?? ''}';
    _sleepCtrl.text = '${profile?.lifestyle['sleep'] ?? ''}';

    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final user = _auth.currentUser;
    if (user == null) return;
    setState(() => _saving = true);

    try {
      await _db.updateUserProfileFields(
        user.uid,
        name: _nameCtrl.text.trim(),
        profileImageUrl: _imageCtrl.text.trim(),
        metrics: {
          'age': int.tryParse(_ageCtrl.text.trim()) ?? 0,
          'height': double.tryParse(_heightCtrl.text.trim()) ?? 0.0,
          'weight': double.tryParse(_weightCtrl.text.trim()) ?? 0.0,
        },
        lifestyle: {'sleep': double.tryParse(_sleepCtrl.text.trim()) ?? 7.0},
      );
      await widget.onProfileUpdated();
      HapticsService.success();
      if (!mounted) return;
      _showBottomToast(context, 'Profile updated');
    } catch (e) {
      HapticsService.error();
      if (!mounted) return;
      _showBottomToast(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final email = _auth.currentUser?.email ?? 'member@liftlab.app';
    final image = _imageCtrl.text.trim();
    final initial =
        (_nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : email)[0]
            .toUpperCase();

    if (_loading) return const Center(child: CircularProgressIndicator());

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Text('Profile', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Account',
            order: 0,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.primary.withValues(alpha: 0.2),
                  backgroundImage:
                      (image.isNotEmpty &&
                          Uri.tryParse(image)?.hasAbsolutePath == true)
                      ? NetworkImage(image)
                      : null,
                  child: image.isEmpty
                      ? Text(
                          initial,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Fetched from backend profile',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Appearance',
            order: 1,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark mode'),
              subtitle: Text(
                ThemeService.isDark ? 'Enabled' : 'Disabled (default light)',
              ),
              value: ThemeService.isDark,
              onChanged: (value) {
                HapticsService.selection();
                setState(() => ThemeService.setDark(value));
              },
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Edit Details',
            order: 2,
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _imageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Profile Image URL',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Age'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _heightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _sleepCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Sleep (h)',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: const Text('Save Profile'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              HapticsService.medium();
              await _auth.signOut();
              if (!context.mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = _metricAccent(label, colors);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child, this.order = 0});
  final String title;
  final Widget child;
  final int order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = _cardAccent(title, colors);
    final revealStart = (order * 0.08).clamp(0.0, 0.55);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 720),
      curve: Interval(revealStart, 1.0, curve: Curves.easeOutCubic),
      builder: (context, value, cardChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: cardChild,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(accent.withValues(alpha: 0.10), colors.surface),
              colors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.onSurface.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatefulWidget {
  const _ActionPill({
    required this.icon,
    required this.text,
    required this.onTap,
  });
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = widget.text.toLowerCase().contains('ai')
        ? colors.secondary
        : colors.primary;
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onHighlightChanged: (value) => setState(() => _pressed = value),
        onTap: () {
          HapticsService.selection();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: _pressed ? 0.28 : 0.22),
                colors.tertiary.withValues(alpha: _pressed ? 0.24 : 0.18),
              ],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 15, color: accent),
              const SizedBox(width: 6),
              Text(widget.text),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.current,
    required this.target,
  });
  final String label;
  final int current;
  final int target;

  @override
  Widget build(BuildContext context) {
    final clamped = target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final colors = Theme.of(context).colorScheme;
    final accent = _macroAccent(label, colors);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(label), Text('$current / $target')],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: clamped,
              backgroundColor: colors.onSurface.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }
}

Color _navAccent(int index, ColorScheme colors) {
  switch (index) {
    case 0:
      return colors.primary;
    case 1:
      return colors.secondary;
    case 2:
      return colors.tertiary;
    case 3:
      return const Color(0xFFEF6C00);
    default:
      return const Color(0xFF9C27B0);
  }
}

Color _cardAccent(String title, ColorScheme colors) {
  final key = title.toLowerCase();
  if (key.contains('snapshot') || key.contains('summary')) {
    return colors.primary;
  }
  if (key.contains('quick') || key.contains('session')) {
    return colors.secondary;
  }
  if (key.contains('nutrition') ||
      key.contains('meal') ||
      key.contains('macro')) {
    return colors.tertiary;
  }
  if (key.contains('history') || key.contains('recent')) {
    return const Color(0xFFEF6C00);
  }
  if (key.contains('profile') ||
      key.contains('appearance') ||
      key.contains('account')) {
    return const Color(0xFF9C27B0);
  }
  return colors.primary;
}

Color _macroAccent(String label, ColorScheme colors) {
  final key = label.toLowerCase();
  if (key.contains('cal')) return const Color(0xFFEF6C00);
  if (key.contains('protein')) return colors.primary;
  if (key.contains('carb')) return colors.secondary;
  if (key.contains('fat')) return const Color(0xFF9C27B0);
  return colors.primary;
}

Color _metricAccent(String label, ColorScheme colors) {
  final key = label.toLowerCase();
  if (key.contains('goal')) return colors.primary;
  if (key.contains('streak')) return colors.secondary;
  if (key.contains('protein')) return colors.tertiary;
  return colors.primary;
}

class _HomeData {
  _HomeData({
    required this.profile,
    required this.workouts,
    required this.todayNutrition,
  });
  final UserModel? profile;
  final List<Map<String, dynamic>> workouts;
  final List<Map<String, dynamic>> todayNutrition;
}

class _HistoryData {
  _HistoryData({
    required this.workouts,
    required this.nutrition,
    required this.profile,
  });
  final List<Map<String, dynamic>> workouts;
  final List<Map<String, dynamic>> nutrition;
  final UserModel? profile;
}

DateTime? _toDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

String _fmtDate(DateTime? date) {
  if (date == null) return 'just now';
  final hh = date.hour.toString().padLeft(2, '0');
  final mm = date.minute.toString().padLeft(2, '0');
  return '${date.day}/${date.month} $hh:$mm';
}

String _fmtDuration(int seconds) {
  final h = (seconds ~/ 3600).toString().padLeft(2, '0');
  final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

void _showBottomToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  final colors = Theme.of(context).colorScheme;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color.alphaBlend(
        colors.primary.withValues(alpha: 0.18),
        colors.surface,
      ),
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 124),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
