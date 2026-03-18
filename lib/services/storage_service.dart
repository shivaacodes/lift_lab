import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lift_lab/services/auth_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _auth = AuthService();

  /// Uploads a profile image for the current user and returns the download URL.
  Future<String> uploadProfileImage(File file) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    try {
      final ref = _storage.ref().child('profiles').child('${user.uid}.jpg');
      
      // Upload task
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Error uploading profile image: $e';
    }
  }
}
