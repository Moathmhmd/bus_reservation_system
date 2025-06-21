import 'package:bus_reservation_system/Services/app_data.dart';
import 'package:bus_reservation_system/Services/bus_service.dart';
import 'package:bus_reservation_system/widgets/bus_card.dart';
import 'package:bus_reservation_system/widgets/bus_form_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusManagementPage extends StatefulWidget {
  const BusManagementPage({super.key});

  @override
  State<BusManagementPage> createState() => _BusManagementPageState();
}

class _BusManagementPageState extends State<BusManagementPage> {
  final BusService _busService = BusService();
  String? company;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    setState(() {
      company = AppData().company;
    });
  }

  void _openBusForm({DocumentSnapshot? busDoc}) {
    showDialog(
      context: context,
      builder: (_) => BusFormPopup(
        busDoc: busDoc,
        onSaved: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (company == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Bus Management"),
        backgroundColor: Colors.amber,
      ),
      body: StreamBuilder(
        stream: _busService.fetchBusesByCompany(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final buses = snapshot.data!.docs;

          if (buses.isEmpty) {
            return Center(child: Text("No buses found"));
          }

          return ListView.builder(
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              return BusCard(
                busDoc: bus,
                onTap: () => _openBusForm(busDoc: bus),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openBusForm(),
        backgroundColor: Colors.amber,
        child: Icon(Icons.add),
      ),
    );
  }
}
