import 'package:bus_reservation_system/Services/app_data.dart';
import 'package:bus_reservation_system/pages/admin/admin_home_page.dart';
import 'package:bus_reservation_system/pages/boarding_page.dart';
import 'package:bus_reservation_system/pages/driver/driver_home_page.dart';
import 'package:bus_reservation_system/pages/user/user_home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          User? user = snapshot.data;

          // Fetch user role from Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error loading user data')),
                );
              }

              // Check if the document exists (user is deleted)
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                // If the user doesn't exist in Firestore (i.e., user deleted), log out and show BoardingPage
                FirebaseAuth.instance.signOut();
                return BoardingPage(); // Redirect to boarding page if the user is deleted
              }

              // Get user role from Firestore
              String role = userSnapshot.data!['role'];

              if (role == 'admin') {
                AppData().uid = user.uid;
                AppData().company = userSnapshot.data!['company'];
              }
              // Navigate based on role
              if (role == 'admin') {
                return AdminHomePage(); // Navigate to Admin Home page
              } else if (role == 'driver') {
                return DriverHomePage(); // Navigate to Driver Home page
              } else if (role == 'user') {
                return UserHomePage(); // Navigate to User Home page
              } else {
                return BoardingPage();
              }
            },
          );
        }

        // 3. User is NOT logged in
        return BoardingPage(); // Show BoardingPage if user is not logged in
      },
    );
  }
}
