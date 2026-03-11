class AiCoachService {
  static String workoutSwapSuggestion({
    required String goal,
    required String exercise,
    required String gymAccess,
  }) {
    final bool homeOnly =
        gymAccess.toLowerCase().contains('bodyweight') ||
        gymAccess.toLowerCase().contains('home');

    if (homeOnly) {
      if (exercise.toLowerCase().contains('bench')) {
        return 'Push-Ups (tempo 3-1-1)';
      }
      if (exercise.toLowerCase().contains('row')) {
        return 'Inverted Rows';
      }
      if (exercise.toLowerCase().contains('squat')) {
        return 'Bulgarian Split Squats';
      }
      return 'Single-Leg Variation + Slow Eccentrics';
    }

    if (goal.toLowerCase().contains('strength')) {
      return 'Swap to a compound variation with lower reps (4-6).';
    }
    if (goal.toLowerCase().contains('fat')) {
      return 'Swap to circuit format with 45-60s rest.';
    }
    return 'Swap to a machine/isolation variation for joint-friendly volume.';
  }

  static String mealSuggestion({
    required int remainingCalories,
    required int remainingProtein,
    required int remainingCarbs,
    required int remainingFats,
  }) {
    if (remainingProtein > 45 && remainingCalories > 350) {
      return 'AI Meal: Grilled chicken wrap + Greek yogurt (high protein top-up).';
    }
    if (remainingCarbs > 60 && remainingCalories > 300) {
      return 'AI Meal: Rice bowl with beans + veggies (carb-focused refill).';
    }
    if (remainingFats > 20) {
      return 'AI Meal: Omelette + avocado toast (healthy fat balance).';
    }
    return 'AI Meal: Cottage cheese, fruit, and nuts (balanced light meal).';
  }

  static String weeklyInsight({
    required int workouts,
    required int avgProtein,
    required int proteinTarget,
  }) {
    final proteinDelta = avgProtein - proteinTarget;
    if (workouts >= 4 && proteinDelta >= 0) {
      return 'AI Insight: Great consistency this week. Keep progressive overload steady.';
    }
    if (workouts < 3) {
      return 'AI Insight: Add one short session to improve momentum next week.';
    }
    if (proteinDelta < 0) {
      return 'AI Insight: Increase daily protein by ${proteinDelta.abs()}g for better recovery.';
    }
    return 'AI Insight: Solid baseline. Focus on sleep and session quality this week.';
  }
}
