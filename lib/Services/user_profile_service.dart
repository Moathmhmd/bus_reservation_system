import 'package:bus_reservation_system/pages/user/user_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> saveUserProfile(UserProfile profile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Not logged in");

    await _db
        .collection('users')
        .doc(uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  static Future<UserProfile?> loadUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return UserProfile.fromMap(doc.data()!);
  }
}
