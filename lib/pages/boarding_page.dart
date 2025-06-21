import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bus_reservation_system/widgets/custom_elevated_button.dart';

class BoardingPage extends StatefulWidget {
  const BoardingPage({super.key});

  @override
  State<BoardingPage> createState() => _BoardingPageState();
}

class _BoardingPageState extends State<BoardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Text(
              "Welcome Onboard!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Select your role to get started",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CustomElevatedButton(
                      text: "Sign Up as User",
                      color: Colors.blueAccent,
                      onPressed: () {
                        Navigator.pushNamed(context, '/signUp',
                            arguments: 'user');
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomElevatedButton(
                      text: "Sign Up as Admin",
                      color: Colors.green,
                      onPressed: () {
                        Navigator.pushNamed(context, '/adminSignUp',
                            arguments: 'admin');
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomElevatedButton(
                      text: "Sign Up as Driver",
                      color: Colors.orange,
                      onPressed: () {
                        Navigator.pushNamed(context, '/driverSignUp',
                            arguments: 'driver');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            RichText(
              text: TextSpan(
                text: "Already have an account? ",
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'Login here',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, '/login');
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
