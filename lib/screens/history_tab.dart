import 'package:flutter/material.dart';
import 'package:lift_lab/models/user_model.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';
import 'package:lift_lab/widgets/app_widgets.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key, required this.profile});
  final UserModel? profile;

  static final _auth = AuthService();
  static final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) return const SizedBox.shrink();
    
    final uid = user.uid;
    final theme = Theme.of(context);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _db.getWorkoutLogsStream(uid, limit: 30),
      builder: (context, workoutSnapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _db.getNutritionLogsStream(uid, limit: 100),
          builder: (context, nutritionSnapshot) {
            final workouts = workoutSnapshot.data ?? [];
            final nutrition = nutritionSnapshot.data ?? [];

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                children: [
                  Text('History', style: theme.textTheme.displayLarge?.copyWith(fontSize: 32)),
                  const SizedBox(height: 28),

                  InfoCard(
                    title: 'Recent Sessions',
                    order: 1,
                    child: workouts.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('No workouts logged yet.', style: theme.textTheme.bodyMedium),
                          )
                        : Column(
                            children: workouts.take(8).map((entry) {
                              final date = toDate(entry['createdAt']);
                              return _HistoryItem(
                                icon: Icons.fitness_center_rounded,
                                title: entry['sessionName']?.toString() ?? 'Workout',
                                subtitle: '${entry['completedSets'] ?? 0} sets • ${fmtDate(date)}',
                                trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.black26),
                              );
                            }).toList(),
                          ),
                  ),

                  InfoCard(
                    title: 'Recent Meals',
                    order: 2,
                    child: nutrition.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('No meal history yet.', style: theme.textTheme.bodyMedium),
                          )
                        : Column(
                            children: nutrition.take(8).map((entry) {
                              final date = toDate(entry['createdAt']);
                              return _HistoryItem(
                                icon: Icons.restaurant_rounded,
                                title: entry['mealName']?.toString() ?? 'Meal',
                                subtitle: '${entry['calories']} kcal • ${fmtDate(date)}',
                                trailing: Text(
                                  '${entry['protein']}g P', 
                                  style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.primary, fontSize: 13),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.icon, required this.title, required this.subtitle, this.trailing});
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x08000000)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black45)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
