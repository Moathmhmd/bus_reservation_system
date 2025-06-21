import 'package:bus_reservation_system/Services/auth_checker.dart';
import 'package:bus_reservation_system/Services/firebase_options.dart';
import 'package:bus_reservation_system/pages/admin/admin_home_page.dart';
import 'package:bus_reservation_system/pages/admin/bus_management_page.dart';
import 'package:bus_reservation_system/pages/admin/route_management_page.dart';
import 'package:bus_reservation_system/pages/admin/schedule_management_page.dart';
import 'package:bus_reservation_system/pages/auth/login_page.dart';
import 'package:bus_reservation_system/pages/auth/signup_page.dart';
import 'package:bus_reservation_system/pages/driver/driver_home_page.dart';
import 'package:bus_reservation_system/pages/user/user_home_page.dart';
import 'package:bus_reservation_system/pages/user/user_tickets_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bus_reservation_system/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => LandingPage(),
        '/home': (context) => HomePage(),
        '/signup': (context) => SignUpPage(role: 'user'),
        '/driverSignUp': (context) => SignUpPage(role: 'driver'),
        '/adminSignUp': (context) => SignUpPage(role: 'admin'),
        '/signUp': (context) => SignUpPage(role: 'user'),
        '/login': (context) => LoginPage(),
        '/userHome': (context) => UserHomePage(),
        '/adminHome': (context) => AdminHomePage(),
        '/driverHome': (context) => DriverHomePage(),
        '/ManageBus': (context) => BusManagementPage(),
        '/ManageRoute': (context) => RouteManagementPage(),
        '/Manageschedule': (context) => AdminSchedulePage(),
        '/UserTicketPage': (context) => UserTicketsPage(),
      },
    );
  }
}
