import 'package:bus_reservation_system/Services/app_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up method
  Future<void> signUp({
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController companyController,
    required String role,
    required BuildContext context,
  }) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String company = companyController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all fields'),
      ));
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      if (role == 'admin') {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'phone': phone,
          'email': email,
          'role': 'admin',
          'company': company,
        });
      }

      if (role == 'driver') {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'phone': phone,
          'email': email,
          'role': 'driver',
          'company': company,
        });
      }

      if (role == 'user') {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'phone': phone,
          'email': email,
          'role': 'user',
        });
      }
      if (role == "admin") {
        await AppData().init(); // Initialize AppData after sign-up
      }

      if (role == 'user') {
        Navigator.pushReplacementNamed(context, '/userHome');
      } else if (role == 'admin') {
        Navigator.pushNamedAndRemoveUntil(
            context, '/adminHome', (route) => true);
      } else if (role == 'driver') {
        Navigator.pushReplacementNamed(context, '/driverHome');
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sign Up Successful'),
      ));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'Error occurred!'),
      ));
    }
  }

  // Sign-in method
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Initialize AppData after login

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sign in Successful'),
        backgroundColor: Colors.green,
      ));

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      String role = userDoc['role'];

      if (role == 'admin') {
        await AppData().init();
        Navigator.pushReplacementNamed(context, '/adminHome');
      } else if (role == 'driver') {
        Navigator.pushReplacementNamed(context, '/driverHome');
      } else {
        Navigator.pushReplacementNamed(context, '/userHome');
      }

      // ignore: unused_catch_clause
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email or password is Incorrect , please try again'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Log out method
  Future<void> signOut() async {
    AppData().clear();
    await _auth.signOut();
  }
}
