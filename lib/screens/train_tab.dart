import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:lift_lab/models/user_model.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';
import 'package:lift_lab/services/haptics_service.dart';
import 'package:lift_lab/widgets/app_widgets.dart';

class TrainTab extends StatefulWidget {
  const TrainTab({super.key, required this.profile});
  final UserModel? profile;

  @override
  State<TrainTab> createState() => _TrainTabState();
}

class _TrainTabState extends State<TrainTab> {
  final _auth = AuthService();
  final _db = DatabaseService();
  late ConfettiController _confettiController;

  // Workout plan state
  List<Map<String, dynamic>>? _todayExercises;
  String _todayLabel = '';
  String _focus = '';
  String _priority = '';
  bool _loading = false;

  // Session tracking
  late List<int> _doneSets; // tracks completed sets per exercise
  bool _savingSession = false;
  bool _sessionSuccess = false;

  @override
  void initState() {

    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _applyProtocolPlan();
  }

  @override
  void didUpdateWidget(TrainTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
      _applyProtocolPlan();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }


  int get _todayDayIndex => DateTime.now().weekday;

  void _applyProtocolPlan() {
    final p = widget.profile;
    if (p == null || p.protocol == null) {
      setState(() {
        _todayLabel = 'Rest';
        _todayExercises = [];
        _doneSets = [];
      });
      return;
    }

    final workout = p.protocol!['workout'] as Map<String, dynamic>;
    final weeklyPlan = List<Map<String, dynamic>>.from(workout['weekly_plan'] ?? []);
    
    final todayData = weeklyPlan.firstWhere(
      (d) => d['day'] == _todayDayIndex,
      orElse: () => {'label': 'Rest Day', 'exercises': []},
    );

    final exercises = List<Map<String, dynamic>>.from(todayData['exercises'] ?? []);
    
    setState(() {
      _focus = workout['focus'] ?? 'General';
      _priority = workout['priority'] ?? 'Sustainability';
      _todayLabel = todayData['label'] ?? 'Training';
      _todayExercises = exercises;
      _doneSets = List.filled(exercises.length, 0);
    });

    _syncTodayProgress();
  }

  Future<void> _syncTodayProgress() async {
    final user = _auth.currentUser;
    if (user == null || _todayExercises == null) return;

    try {
      final logs = await _db.getTodayWorkoutLogs(user.uid);
      if (logs.isEmpty) return;

      final newDoneSets = List<int>.filled(_todayExercises!.length, 0);
      
      for (final log in logs) {
        final logExercises = List<Map<String, dynamic>>.from(log['exercises'] ?? []);
        for (int i = 0; i < _todayExercises!.length; i++) {
          final targetEx = _todayExercises![i];
          final match = logExercises.firstWhere(
            (e) => e['name'] == targetEx['name'],
            orElse: () => {},
          );
          if (match.isNotEmpty) {
            newDoneSets[i] += (match['completedSets'] as num?)?.toInt() ?? 0;
          }
        }
      }

      if (mounted) {
        setState(() {
          _doneSets = newDoneSets;
        });
      }
    } catch (e) {
      debugPrint('Error syncing today progress: $e');
    }
  }


  Future<void> _finishSession() async {
    final user = _auth.currentUser;
    if (user == null || _todayExercises == null) return;

    // Calculate metrics
    int totalBurned = 0;
    final exercises = List.generate(_todayExercises!.length, (i) {
      final ex = Map<String, dynamic>.from(_todayExercises![i]);
      final done = _doneSets[i];
      final target = (ex['sets'] as num?)?.toInt() ?? 3;
      final burnPerSet = ((ex['burnKcal'] ?? 30) as num).toDouble() / target;
      
      totalBurned += (done * burnPerSet).round().toInt();
      ex['completedSets'] = done;
      return ex;
    });

    final completedSets = _doneSets.fold(0, (a, b) => a + b);

    // Calculate state before resetting or showing success
    final totalSets = _todayExercises!.fold<int>(0, (a, e) => a + ((e['sets'] as num?)?.toInt() ?? 3));
    final allComplete = completedSets >= totalSets;

    // ⚡ Optimistic UI Update: Reset state and show success immediately
    HapticsService.success();
    
    if (mounted) {
      if (allComplete) {
        _confettiController.play();
        showBottomToast(context, '🏆 SESSION COMPLETED! — Total $totalBurned kcal!', isSuccess: true);
      } else {
        showBottomToast(context, '✅ PROGRESS SAVED! — $totalBurned kcal tracked.', isSuccess: true);
      }
      
      setState(() {
        _savingSession = false; // Reset loading state instantly
        if (allComplete) _sessionSuccess = true; // Mark as success only if full
      });
    }



    
    // Refresh progress from server to ensure perfect sync
    _syncTodayProgress();

    // 🔬 Background Database Sync (with 5s safety timeout)
    try {
      // We don't 'await' this synchronously to the UI
      _db.logWorkoutSession(
        user.uid,
        sessionName: _todayLabel,
        durationMinutes: 45,
        completedSets: completedSets,
        totalBurnedKcal: totalBurned,
        exercises: exercises,
      ).timeout(const Duration(seconds: 5)).catchError((e) {
        debugPrint('Background Workout Log Error: $e');
        return null;
      });
    } catch (e) {
      debugPrint('Background Session Action Error: $e');
    }
  }

  Widget _buildRestDay() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Text('🛌', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            Text('Protocol Rest', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Your growth phase requires recovery. Your AI protocol suggests focusing on sleep and hydration today.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(int index, Map<String, dynamic> exercise) {
    final theme = Theme.of(context);
    final name = exercise['name'] ?? 'Exercise';
    final sets = (exercise['sets'] as num?)?.toInt() ?? 3;
    final reps = exercise['reps']?.toString() ?? '8-12';
    final done = _doneSets[index];
    final isFull = done >= sets;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFull ? theme.colorScheme.primary.withValues(alpha: 0.4) : const Color(0x0D000000),
          width: isFull ? 2 : 1.5,
        ),
        boxShadow: isFull ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.05), blurRadius: 10)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name, style: theme.textTheme.titleMedium?.copyWith(letterSpacing: -0.2)),
              ),
              if (isFull)
                Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 24),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$sets sets × $reps reps',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
              ),
              const Spacer(),
              Icon(Icons.local_fire_department_rounded, color: Colors.orange.shade700, size: 14),
              const SizedBox(width: 4),
              Text(
                '${exercise['burnKcal'] ?? 30} KCAL',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.orange.shade800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SetControlBtn(
                icon: Icons.remove_rounded,
                onPressed: done > 0 ? () { HapticsService.light(); setState(() => _doneSets[index]--); } : null,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$done / $sets',
                      style: theme.textTheme.titleMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const Text('SETS DONE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black26)),
                  ],
                ),
              ),
              _SetControlBtn(
                icon: Icons.add_rounded,
                onPressed: done < sets ? () { HapticsService.selection(); setState(() => _doneSets[index]++); } : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: sets == 0 ? 0 : done / sets,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(isFull ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final exercises = _todayExercises ?? [];
    if (exercises.isEmpty) return _buildRestDay();

    final totalDone = _doneSets.fold(0, (a, b) => a + b);
    final totalSets = exercises.fold<int>(0, (a, e) => a + ((e['sets'] as num?)?.toInt() ?? 3));
    final allComplete = totalDone >= totalSets;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SafeArea(
          child: Column(
            children: [
              _buildTopBar(theme),
              _buildProtocolHeader(theme),
              _buildSessionProgress(theme, totalDone, totalSets),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 140),
                  itemCount: exercises.length,
                  itemBuilder: (_, i) => _buildExerciseCard(i, exercises[i]),
                ),
              ),
              _buildBottomAction(theme, totalDone, allComplete),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ],
          numberOfParticles: 20,
          gravity: 0.1,
        ),
      ],
    );

  }

  Widget _buildTopBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PROTOCOL', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary, letterSpacing: 1.5)),
              const SizedBox(height: 2),
              Text(_todayLabel, style: theme.textTheme.headlineSmall),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Icon(Icons.timer_outlined, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              const Text('45 MIN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolHeader(ThemeData theme) {
    if (_focus.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.bolt_rounded, color: theme.colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'FOCUS: ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: theme.colorScheme.primary)),
                  TextSpan(text: _focus.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                ]),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'PRIORITY: ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: theme.colorScheme.primary)),
                  TextSpan(text: _priority.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                ]),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionProgress(ThemeData theme, int done, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
      child: Row(
        children: [
          Text(
            '$done / $total',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: total == 0 ? 0 : done / total,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(ThemeData theme, int totalDone, bool allComplete) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (allComplete ? Colors.green : theme.colorScheme.primary).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: (_savingSession || totalDone == 0 || _sessionSuccess) ? null : _finishSession,
          style: ElevatedButton.styleFrom(

            backgroundColor: allComplete ? Colors.green : theme.colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          icon: _savingSession
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Icon(allComplete ? Icons.star_rounded : Icons.check_circle_rounded, size: 24),
          label: Text(
            _savingSession 
                ? 'WRITING LOG…' 
                : _sessionSuccess 
                    ? 'COMPLETED' 
                    : allComplete 
                        ? 'FINISH SESSION' 
                        : 'SAVE PROGRESS',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),


        ),
      ),
    );
  }
}

class _SetControlBtn extends StatelessWidget {
  const _SetControlBtn({required this.icon, this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x0D000000), width: 1.5),
            color: onPressed == null ? const Color(0xFFF8FAFC) : Colors.white,
          ),
          child: Icon(icon, color: onPressed == null ? Colors.black12 : Colors.black87),
        ),
      ),
    );
  }
}
