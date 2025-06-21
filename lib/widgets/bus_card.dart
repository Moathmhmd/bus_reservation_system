import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusCard extends StatelessWidget {
  final DocumentSnapshot busDoc;
  final VoidCallback onTap;

  const BusCard({super.key, required this.busDoc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final data = busDoc.data() as Map<String, dynamic>;

    return Card(
      color: Colors.grey[100],
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        title: Text("Bus: ${data['busNumber']}"),
        subtitle: Text(
            "Driver: ${data['driverName']}\nCapacity: ${data["capacity"]}"),
        trailing: Icon(Icons.edit, color: Colors.amber),
      ),
    );
  }
}
