import 'package:bus_reservation_system/Services/auth_service.dart';
import 'package:bus_reservation_system/widgets/custom_elevated_Button.dart';
import 'package:bus_reservation_system/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailCon = TextEditingController();
  final TextEditingController _passwordCon = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        minimum: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/bus4.jpg', fit: BoxFit.contain),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              CustomTextField(
                controller: _emailCon,
                hintText: "Email",
                icon: Icons.email,
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: _passwordCon,
                hintText: "Password",
                icon: Icons.lock,
                isPassword: true,
              ),
              SizedBox(height: 50),
              CustomElevatedButton(
                text: "Login",
                color: Colors.amber,
                onPressed: () {
                  _authService.login(
                    email: _emailCon.text.trim(),
                    password: _passwordCon.text,
                    context: context,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
