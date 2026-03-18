import 'package:flutter/material.dart';
import 'package:lift_lab/models/user_model.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';
import 'package:lift_lab/widgets/app_widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.profile,
    required this.onOpenTrain,
    required this.onOpenNutrition,
  });

  final UserModel? profile;
  final VoidCallback onOpenTrain;
  final VoidCallback onOpenNutrition;

  static final _db = DatabaseService();
  static final _auth = AuthService();


  Map<String, int> _calculateTargets(UserModel? profile) {
    if (profile?.protocol != null && profile!.protocol!['nutrition'] != null) {
      final n = profile.protocol!['nutrition'] as Map<String, dynamic>;
      return {
        'cal': (n['calories'] as num?)?.toInt() ?? 2400,
        'pro': (n['protein'] as num?)?.toInt() ?? 160,
        'carb': (n['carbs'] as num?)?.toInt() ?? 250,
        'fat': (n['fats'] as num?)?.toInt() ?? 70,
      };
    }

    if (profile == null) return {'cal': 2400, 'pro': 160, 'carb': 250, 'fat': 70};
    
    final weight = (profile.metrics['weight'] as num?)?.toDouble() ?? 70.0;
    int baseCals = (weight * 33).round();
    
    // Adjust based on goal
    final goal = profile.goal.toLowerCase();
    if (goal.contains('hypertrophy')) baseCals += 300;
    else if (goal.contains('fat loss')) baseCals -= 500;
    else if (goal.contains('strength')) baseCals += 150;

    final protein = (weight * 2.2).round();
    final fat = (baseCals * 0.25 / 9).round();
    final carb = ((baseCals - (protein * 4) - (fat * 9)) / 4).round();

    return {'cal': baseCals, 'pro': protein, 'carb': carb, 'fat': fat};
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) return const SizedBox.shrink();
    
    final uid = user.uid;
    final theme = Theme.of(context);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _db.getWorkoutLogsStream(uid, limit: 10),
      builder: (context, workoutSnapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _db.getNutritionLogsStream(uid, limit: 30),
          builder: (context, nutritionSnapshot) {
            final workouts = workoutSnapshot.data ?? [];
            final allNutrition = nutritionSnapshot.data ?? [];

            final now = DateTime.now();
            final todayNutrition = allNutrition.where((n) {
              final date = toDate(n['createdAt']);
              if (date == null) return true; 
              return date.year == now.year && date.month == now.month && date.day == now.day;
            }).toList();

            final todayWorkouts = workouts.where((w) {
              final date = toDate(w['createdAt']);
              if (date == null) return true;
              return date.year == now.year && date.month == now.month && date.day == now.day;
            }).toList();

            final name = (profile?.name.isNotEmpty ?? false)
                ? profile!.name
                : (_auth.currentUser?.email ?? 'Member').split('@').first;
            
            final targets = _calculateTargets(profile);
            
            final consumedToday = todayNutrition.fold<int>(0, (t, e) => t + ((e['calories'] ?? 0) as num).toInt());
            final burnedToday   = todayWorkouts.fold<int>(0, (t, e) => t + ((e['totalBurnedKcal'] ?? 0) as num).toInt());
            
            // Net calories = Consumed - Burned
            final netCaloriesToday = (consumedToday - burnedToday).clamp(0, 99999);

            final proteinToday  = todayNutrition.fold<int>(0, (t, e) => t + ((e['protein']  ?? 0) as num).toInt());
            final carbsToday    = todayNutrition.fold<int>(0, (t, e) => t + ((e['carbs']    ?? 0) as num).toInt());
            final fatsToday     = todayNutrition.fold<int>(0, (t, e) => t + ((e['fats']     ?? 0) as num).toInt());

            final latestWorkout = workouts.isNotEmpty ? workouts.first : null;
            final latestMeal    = allNutrition.isNotEmpty ? allNutrition.first : null;
            final profileImg    = profile?.profileImageUrl;

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(name, style: theme.textTheme.displayLarge?.copyWith(fontSize: 32, letterSpacing: -1.0)),
                        ],
                      ),
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 2),
                          image: (profileImg != null && profileImg.isNotEmpty)
                              ? DecorationImage(image: NetworkImage(profileImg), fit: BoxFit.cover)
                              : null,
                        ),
                        child: (profileImg == null || profileImg.isEmpty)
                            ? Center(child: Text(name[0].toUpperCase(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)))
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Nutrition progress ──────────────────────────────────
                  InfoCard(
                    title: 'Nutrition Lab',
                    order: 1,
                    child: Column(children: [
                      MacroRow(label: 'Net Calories', current: netCaloriesToday, target: targets['cal']!),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(child: MacroRow(label: 'Protein', current: proteinToday, target: targets['pro']!)),
                          const SizedBox(width: 16),
                          Expanded(child: MacroRow(label: 'Carbs',   current: carbsToday,   target: targets['carb']!)),
                        ],
                      ),
                      MacroRow(label: 'Fats', current: fatsToday, target: targets['fat']!),
                      
                      if (latestMeal != null)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.restaurant_rounded, size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Last: ${latestMeal['mealName'] ?? 'Meal'} (${latestMeal['calories']} kcal)',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ]),
                  ),

                  // ── Last workout ────────────────────────────────────────
                  InfoCard(
                    title: 'Latest Activity',
                    order: 2,
                    child: latestWorkout == null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No sessions logged yet. Ready to lift?',
                              style: theme.textTheme.bodyMedium,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0x0D000000)),
                                ),
                                child: Icon(Icons.fitness_center_rounded, color: theme.colorScheme.primary, size: 20),
                              ),
                              title: Text(
                                latestWorkout['sessionName'] ?? 'Session',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              subtitle: Text(
                                '${latestWorkout['completedSets'] ?? 0} sets • ${fmtDate(toDate(latestWorkout['createdAt']))}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: onOpenTrain,
                            ),
                          ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ActionPill(
                          icon: Icons.add_rounded,
                          text: 'Log Meal',
                          onTap: onOpenNutrition,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionPill(
                          icon: Icons.play_arrow_rounded,
                          text: 'Start Train',
                          onTap: onOpenTrain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
