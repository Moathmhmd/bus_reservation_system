import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus_reservation_system/Services/route_service.dart';
import 'package:bus_reservation_system/Widgets/route_form_popup.dart';

class RouteManagementPage extends StatefulWidget {
  const RouteManagementPage({super.key});

  @override
  State<RouteManagementPage> createState() => _RouteManagementPageState();
}

class _RouteManagementPageState extends State<RouteManagementPage> {
  final RouteService _routeService = RouteService();

  void _openRouteDialog({DocumentSnapshot? doc}) {
    showDialog(
      context: context,
      builder: (_) => RouteFormPopup(
        doc: doc,
        onSaved: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text("Route Management"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _routeService.getRoutesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No routes found."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                color: Colors.grey[100],
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(doc['name']),
                  subtitle: Text(
                    "${doc['startLocation']['name']} → ${doc['endLocation']['name']}\n${doc['estimatedDuration']}",
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _routeService.deleteRoute(doc.id);
                    },
                  ),
                  onTap: () => _openRouteDialog(doc: doc),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => _openRouteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
