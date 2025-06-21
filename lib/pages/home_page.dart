import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              // Optionally navigate to login or boarding screen
              Navigator.pushReplacementNamed(context, '/');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("signout successfull"),
                backgroundColor: Colors.grey,
              ));
            },
            icon: Icon(Icons.logout_outlined),
          )
        ],
      )),
    );
  }
}
