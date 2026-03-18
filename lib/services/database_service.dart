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

  // Get User Profile - Real-time Stream
  Stream<UserModel?> getUserProfileStream(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Legacy Future method for one-time checks (optional but kept for internal use if needed)
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
    required int totalBurnedKcal,
    required List<Map<String, dynamic>> exercises,
  }) async {
    try {
      await Future.wait([
        _userDoc(uid).collection('workout_logs').add({
          'sessionName': sessionName,
          'durationMinutes': durationMinutes,
          'completedSets': completedSets,
          'totalBurnedKcal': totalBurnedKcal,
          'exercises': exercises,
          'createdAt': FieldValue.serverTimestamp(),
        }),
        logActivity(uid, 'workout', {
          'sessionName': sessionName,
          'durationMinutes': durationMinutes,
          'completedSets': completedSets,
          'totalBurnedKcal': totalBurnedKcal,
        }),
      ]);
    } catch (e) {
      throw 'Error logging workout session: $e';
    }
  }

  /// Saves a Groq-generated workout plan to Firestore (cached per user).
  Future<void> saveWorkoutPlan(String uid, Map<String, dynamic> plan) async {
    await _userDoc(uid).set({'workoutPlan': plan}, SetOptions(merge: true));
  }

  /// Retrieves the cached workout plan for a user, or null if none exists.
  Future<Map<String, dynamic>?> getWorkoutPlan(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null || data['workoutPlan'] == null) return null;
    return Map<String, dynamic>.from(data['workoutPlan'] as Map);
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
      await Future.wait([
        _userDoc(uid).collection('nutrition_logs').add({
          'mealName': mealName,
          'calories': calories,
          'protein': protein,
          'carbs': carbs,
          'fats': fats,
          'createdAt': FieldValue.serverTimestamp(),
        }),
        logActivity(uid, 'nutrition', {
          'mealName': mealName,
          'calories': calories,
          'protein': protein,
        }),
      ]);
    } catch (e) {
      throw 'Error logging nutrition entry: $e';
    }
  }

  Stream<List<Map<String, dynamic>>> getWorkoutLogsStream(String uid, {int limit = 20}) {
    return _userDoc(uid)
        .collection('workout_logs')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
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

  Stream<List<Map<String, dynamic>>> getNutritionLogsStream(String uid, {int limit = 40}) {
    return _userDoc(uid)
        .collection('nutrition_logs')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
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

  Stream<List<Map<String, dynamic>>> getTodayNutritionLogsStream(String uid) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return _userDoc(uid)
        .collection('nutrition_logs')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
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

  Future<List<Map<String, dynamic>>> getTodayWorkoutLogs(String uid) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    try {
      final snapshot = await _userDoc(uid)
          .collection('workout_logs')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end))
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

}

