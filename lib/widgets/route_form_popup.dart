import 'package:bus_reservation_system/Services/app_data.dart';
import 'package:bus_reservation_system/Services/route_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RouteFormPopup extends StatefulWidget {
  final DocumentSnapshot? doc;
  final VoidCallback onSaved;

  const RouteFormPopup({super.key, this.doc, required this.onSaved});

  @override
  State<RouteFormPopup> createState() => _RouteFormPopupState();
}

class _RouteFormPopupState extends State<RouteFormPopup> {
  final _formKey = GlobalKey<FormState>();
  final _routeService = RouteService();

  late TextEditingController nameCon;
  late TextEditingController durationCon;
  late TextEditingController startNameCon;
  late TextEditingController startLatCon;
  late TextEditingController startLngCon;
  late TextEditingController endNameCon;
  late TextEditingController endLatCon;
  late TextEditingController endLngCon;

  List<Map<String, dynamic>> stops = [];

  @override
  void initState() {
    super.initState();
    final doc = widget.doc;
    nameCon = TextEditingController(text: doc?['name'] ?? '');
    durationCon = TextEditingController(text: doc?['estimatedDuration'] ?? '');
    startNameCon =
        TextEditingController(text: doc?['startLocation']?['name'] ?? '');
    startLatCon = TextEditingController(
        text: doc?['startLocation']?['lat']?.toString() ?? '');
    startLngCon = TextEditingController(
        text: doc?['startLocation']?['lng']?.toString() ?? '');
    endNameCon =
        TextEditingController(text: doc?['endLocation']?['name'] ?? '');
    endLatCon = TextEditingController(
        text: doc?['endLocation']?['lat']?.toString() ?? '');
    endLngCon = TextEditingController(
        text: doc?['endLocation']?['lng']?.toString() ?? '');
    stops = doc != null ? List<Map<String, dynamic>>.from(doc['stops']) : [];
  }

  void addStop() {
    setState(() => stops.add({'name': '', 'lat': 0.0, 'lng': 0.0}));
  }

  void removeStop(int index) {
    setState(() => stops.removeAt(index));
  }

  void saveRoute() async {
    if (!_formKey.currentState!.validate()) return;

    final routeData = {
      'name': nameCon.text,
      'company': AppData().company,
      'startLocation': {
        'name': startNameCon.text,
        'lat': double.tryParse(startLatCon.text) ?? 0.0,
        'lng': double.tryParse(startLngCon.text) ?? 0.0,
      },
      'endLocation': {
        'name': endNameCon.text,
        'lat': double.tryParse(endLatCon.text) ?? 0.0,
        'lng': double.tryParse(endLngCon.text) ?? 0.0,
      },
      'stops': stops,
      'estimatedDuration': durationCon.text,
    };

    await _routeService.addOrUpdateRoute(routeData, docId: widget.doc?.id);
    Navigator.pop(context);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.doc != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(isEditing ? 'Edit Route' : 'Add New Route'),
      content: StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCon,
                  decoration: InputDecoration(labelText: 'Route Name'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: durationCon,
                  decoration: InputDecoration(labelText: 'Estimated Duration'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Text("Start Location",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: startNameCon,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: startLatCon,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Latitude'),
                  validator: (val) => double.tryParse(val ?? '') == null
                      ? 'Enter valid number'
                      : null,
                ),
                TextFormField(
                  controller: startLngCon,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Longitude'),
                  validator: (val) => double.tryParse(val ?? '') == null
                      ? 'Enter valid number'
                      : null,
                ),
                const SizedBox(height: 12),
                Text("End Location",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: endNameCon,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: endLatCon,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Latitude'),
                  validator: (val) => double.tryParse(val ?? '') == null
                      ? 'Enter valid number'
                      : null,
                ),
                TextFormField(
                  controller: endLngCon,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Longitude'),
                  validator: (val) => double.tryParse(val ?? '') == null
                      ? 'Enter valid number'
                      : null,
                ),
                const SizedBox(height: 12),
                Text("Stops", style: TextStyle(fontWeight: FontWeight.bold)),
                ...stops.asMap().entries.map((entry) {
                  int index = entry.key;
                  var stop = entry.value;
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: stop['name'],
                              decoration:
                                  InputDecoration(labelText: 'Stop Name'),
                              onChanged: (val) => stop['name'] = val,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          IconButton(
                            onPressed: () => removeStop(index),
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: stop['lat'].toString(),
                        decoration: InputDecoration(labelText: 'Latitude'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            stop['lat'] = double.tryParse(val) ?? 0.0,
                        validator: (val) => double.tryParse(val ?? '') == null
                            ? 'Enter valid number'
                            : null,
                      ),
                      TextFormField(
                        initialValue: stop['lng'].toString(),
                        decoration: InputDecoration(labelText: 'Longitude'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            stop['lng'] = double.tryParse(val) ?? 0.0,
                        validator: (val) => double.tryParse(val ?? '') == null
                            ? 'Enter valid number'
                            : null,
                      ),
                    ],
                  );
                }).toList(),
                TextButton(onPressed: addStop, child: Text("Add Stop")),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: saveRoute,
            child: Text(isEditing ? 'Save Changes' : 'Add Route')),
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel")),
      ],
    );
  }
}
