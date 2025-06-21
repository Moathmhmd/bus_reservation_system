import 'package:bus_reservation_system/Services/app_data.dart';
import 'package:bus_reservation_system/Services/bus_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusFormPopup extends StatefulWidget {
  final DocumentSnapshot? busDoc;
  final VoidCallback onSaved;

  const BusFormPopup({
    super.key,
    this.busDoc,
    required this.onSaved,
  });

  @override
  State<BusFormPopup> createState() => _BusFormPopupState();
}

class _BusFormPopupState extends State<BusFormPopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _busNumberCon = TextEditingController();
  final TextEditingController _capacityCon = TextEditingController();

  String? _selectedDriverUid;
  String? _selectedDriverName;

  List<Map<String, dynamic>> _drivers = [];

  final BusService _busService = BusService();
  String? _company;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _company = AppData().company;

    if (_company == null) return;

    try {
      _drivers = await _busService.fetchDrivers();

      // Generate route labels

      // If editing, pre-fill form fields with existing bus data
      if (widget.busDoc != null) {
        final busData = widget.busDoc!.data() as Map<String, dynamic>;
        _busNumberCon.text = busData['busNumber'] ?? '';
        _capacityCon.text = busData['capacity'].toString();
        _selectedDriverUid = busData['driverId'];
        _selectedDriverName = busData['driverName'];
      }

      setState(() {});
    } catch (e) {
      // Handle any errors with data fetching
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching data: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _saveBus() async {
    if (!_formKey.currentState!.validate() ||
        _company == null ||
        _selectedDriverUid == null) {
      if (_selectedDriverUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select a driver'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }

    final busData = {
      'busNumber': _busNumberCon.text.trim(),
      'capacity': int.tryParse(_capacityCon.text.trim()) ?? 0,
      'driverId': _selectedDriverUid,
      'driverName': _selectedDriverName,
      'status': 'on_time',
      'company': _company,
      'currentLocation': '',
    };

    if (widget.busDoc != null) {
      await _busService.updateBus(widget.busDoc!.id, busData);
    } else {
      await _busService.addBus(busData);
    }

    Navigator.pop(context);
    widget.onSaved();
  }

  void _deleteBus() async {
    if (widget.busDoc != null) {
      await _busService.deleteBus(widget.busDoc!.id);
      Navigator.pop(context);
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(widget.busDoc != null ? "Edit Bus" : "Add New Bus"),
      content: _company == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _busNumberCon,
                      decoration: InputDecoration(labelText: 'Bus Number'),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _capacityCon,
                      decoration: InputDecoration(labelText: 'Capacity'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedDriverUid,
                      decoration: InputDecoration(labelText: 'Select Driver'),
                      validator: (val) =>
                          val == null ? 'Please select a driver' : null,
                      items: _drivers.map<DropdownMenuItem<String>>((driver) {
                        return DropdownMenuItem<String>(
                          value: driver['uid'],
                          child: Text(driver['name']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDriverUid = val;
                          _selectedDriverName = _drivers
                              .firstWhere((d) => d['uid'] == val)['name'];
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        if (widget.busDoc != null)
          TextButton(
              onPressed: _deleteBus,
              child: Text("Delete", style: TextStyle(color: Colors.red))),
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ElevatedButton(onPressed: _saveBus, child: Text("Save")),
      ],
    );
  }
}
