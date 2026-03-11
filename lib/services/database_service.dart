import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lift_lab/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  // Create or Update User Profile
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _userDoc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw 'Error saving user profile: $e';
    }
  }

  Future<void> updateUserProfileFields(
    String uid, {
    String? name,
    String? profileImageUrl,
    String? goal,
    String? experienceLevel,
    Map<String, dynamic>? metrics,
    Map<String, dynamic>? lifestyle,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (name != null) updates['name'] = name;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      if (goal != null) updates['goal'] = goal;
      if (experienceLevel != null) updates['experienceLevel'] = experienceLevel;
      if (metrics != null) updates['metrics'] = metrics;
      if (lifestyle != null) updates['lifestyle'] = lifestyle;

      await _userDoc(uid).set(updates, SetOptions(merge: true));
    } catch (e) {
      throw 'Error updating profile: $e';
    }
  }

  // Get User Profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _userDoc(
        uid,
      ).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Error fetching user profile: $e';
    }
  }

  Future<void> logWorkoutSession(
    String uid, {
    required String sessionName,
    required int durationMinutes,
    required int completedSets,
    required List<Map<String, dynamic>> exercises,
  }) async {
    try {
      await _userDoc(uid).collection('workout_logs').add({
        'sessionName': sessionName,
        'durationMinutes': durationMinutes,
        'completedSets': completedSets,
        'exercises': exercises,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await logActivity(uid, 'workout', {
        'sessionName': sessionName,
        'durationMinutes': durationMinutes,
        'completedSets': completedSets,
      });
    } catch (e) {
      throw 'Error logging workout session: $e';
    }
  }

  Future<void> logNutritionEntry(
    String uid, {
    required String mealName,
    required int calories,
    required int protein,
    required int carbs,
    required int fats,
  }) async {
    try {
      await _userDoc(uid).collection('nutrition_logs').add({
        'mealName': mealName,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await logActivity(uid, 'nutrition', {
        'mealName': mealName,
        'calories': calories,
        'protein': protein,
      });
    } catch (e) {
      throw 'Error logging nutrition entry: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getRecentWorkoutLogs(
    String uid, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _userDoc(uid)
          .collection('workout_logs')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentNutritionLogs(
    String uid, {
    int limit = 40,
  }) async {
    try {
      final snapshot = await _userDoc(uid)
          .collection('nutrition_logs')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> getTodayNutritionLogs(String uid) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    try {
      final snapshot = await _userDoc(uid)
          .collection('nutrition_logs')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end))
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  // Log user activity for timeline
  Future<void> logActivity(
    String uid,
    String activityType,
    Map<String, dynamic> data,
  ) async {
    try {
      await _userDoc(uid).collection('history').add({
        'type': activityType,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error logging activity: $e';
    }
  }

  // Get today's routine from the global 'routines' collection in Firestore
  Future<Map<String, dynamic>> getDailyRoutine() async {
    final int weekday = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    String dayType = 'Rest Day';

    if (weekday == DateTime.monday || weekday == DateTime.thursday) {
      dayType = 'Push Day';
    } else if (weekday == DateTime.tuesday || weekday == DateTime.friday) {
      dayType = 'Pull Day';
    } else if (weekday == DateTime.wednesday || weekday == DateTime.saturday) {
      dayType = 'Leg Day';
    }

    if (dayType == 'Rest Day') {
      return {'dayName': 'Rest Day', 'exercises': []};
    }

    try {
      final snapshot = await _firestore
          .collection('routines')
          .doc(dayType.toLowerCase().replaceAll(' ', '_'))
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!;
      } else {
        // Fallback or trigger seed if missing
        await seedDailyRoutinesIfEmpty();
        final retrySnapshot = await _firestore
            .collection('routines')
            .doc(dayType.toLowerCase().replaceAll(' ', '_'))
            .get();
        if (retrySnapshot.exists && retrySnapshot.data() != null) {
          return retrySnapshot.data()!;
        }
      }
    } catch (e) {
      print('Error fetching routine from DB: $e');
    }

    // Ultimate fallback if offline or DB fails
    return {'dayName': dayType, 'exercises': []};
  }

  // Seed the routines into Firestore so they are genuinely coming from the DB
  Future<void> seedDailyRoutinesIfEmpty() async {
    try {
      final pushRef = _firestore.collection('routines').doc('push_day');
      final pushDoc = await pushRef.get();

      if (!pushDoc.exists) {
        await pushRef.set({
          'dayName': 'Push Day',
          'exercises': [
            {'name': 'Bench Press', 'details': '4 sets x 8 reps', 'rpe': 'RPE 8'},
            {'name': 'Overhead Press', 'details': '3 sets x 10 reps', 'rpe': 'RPE 8'},
            {'name': 'Incline Dumbbell Press', 'details': '3 sets x 10 reps', 'rpe': 'RPE 8'},
            {'name': 'Tricep Pushdowns', 'details': '3 sets x 12 reps', 'rpe': 'RPE 9'},
            {'name': 'Lateral Raises', 'details': '4 sets x 15 reps', 'rpe': 'RPE 9'},
          ],
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('routines').doc('pull_day').set({
          'dayName': 'Pull Day',
          'exercises': [
            {'name': 'Deadlift', 'details': '3 sets x 5 reps', 'rpe': 'RPE 8'},
            {'name': 'Pull-ups', 'details': '3 sets x 8-10 reps', 'rpe': 'RPE 8'},
            {'name': 'Barbell Rows', 'details': '3 sets x 10 reps', 'rpe': 'RPE 8'},
            {'name': 'Face Pulls', 'details': '3 sets x 15 reps', 'rpe': 'RPE 9'},
            {'name': 'Bicep Curls', 'details': '3 sets x 12 reps', 'rpe': 'RPE 9'},
          ],
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('routines').doc('leg_day').set({
          'dayName': 'Leg Day',
          'exercises': [
            {'name': 'Squats', 'details': '4 sets x 8 reps', 'rpe': 'RPE 8'},
            {'name': 'Leg Press', 'details': '3 sets x 10 reps', 'rpe': 'RPE 8'},
            {'name': 'Romanian Deadlift', 'details': '3 sets x 10 reps', 'rpe': 'RPE 8'},
            {'name': 'Leg Extensions', 'details': '3 sets x 15 reps', 'rpe': 'RPE 9'},
            {'name': 'Calf Raises', 'details': '4 sets x 15 reps', 'rpe': 'RPE 9'},
          ],
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Successfully seeded 3 daily routines into Firestore.');
      }
    } catch (e) {
      print('Error seeding routines: $e');
    }
  }
}
