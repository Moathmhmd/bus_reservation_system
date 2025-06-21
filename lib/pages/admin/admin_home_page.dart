import 'package:bus_reservation_system/Services/app_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildCountStreamCard(
              context: context,
              title: 'Manage Buses',
              color: Colors.blue,
              icon: Icons.directions_bus,
              collectionName: 'buses',
              routeName: '/ManageBus',
            ),
            _buildCountStreamCard(
              context: context,
              title: 'Manage Routes',
              color: Colors.green,
              icon: Icons.alt_route,
              collectionName: 'routes',
              routeName: '/ManageRoute',
            ),
            _buildCountStreamCard(
              context: context,
              title: 'Manage Schedules',
              color: Colors.orange,
              icon: Icons.event_available,
              collectionName: 'schedules',
              routeName: '/Manageschedule',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountStreamCard({
    required BuildContext context,
    required String title,
    required Color color,
    required IconData icon,
    required String collectionName,
    required String routeName,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(collectionName)
          .where('company', isEqualTo: AppData().company)
          .snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, routeName),
          child: Card(
            color: Colors.grey[100],
            margin: EdgeInsets.symmetric(vertical: 10),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          count.toString(),
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: color),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
