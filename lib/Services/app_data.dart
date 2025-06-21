import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppData {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  List<dynamic> routes = [];
  AppData._internal();

  String? company;
  String? uid;

  Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      company = doc['company'];
    }
  }

  void clear() {
    company = null;
    uid = null;
  }

  
}
