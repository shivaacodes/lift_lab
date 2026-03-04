import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lift_lab/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or Update User Profile
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw 'Error saving user profile: $e';
    }
  }

  // Get User Profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Error fetching user profile: $e';
    }
  }

  // Log User Activity (Example: Workout Completed)
  Future<void> logActivity(String uid, String activityType, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('history')
          .add({
        'type': activityType,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error logging activity: $e';
    }
  }
}
