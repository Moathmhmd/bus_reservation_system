import 'package:bus_reservation_system/Services/admin_schedule_service.dart';
import 'package:flutter/material.dart';

class ScheduleFormPage extends StatefulWidget {
  final DateTime day;
  final Map<String, dynamic>? existingData;
  const ScheduleFormPage({super.key, required this.day, this.existingData});

  @override
  State<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

class _ScheduleFormPageState extends State<ScheduleFormPage> {
  String? selectedBus, selectedRoute;
  TimeOfDay? departure, arrival;
  final priceController = TextEditingController();
  Map<String, List<Map<String, dynamic>>> dropdowns = {};

  @override
  void initState() {
    super.initState();
    _loadDropdowns();
    if (widget.existingData != null) {
      final data = widget.existingData!;
      selectedBus = data["busId"];
      selectedRoute = data["routeId"];
      departure = _parseTime(data["departureTime"]);
      arrival = _parseTime(data["arrivalTime"]);
      priceController.text = data["price"]?.toString() ?? "";
    }
  }

  Future<void> _loadDropdowns() async {
    dropdowns = await ScheduleService.fetchDropdownOptions();
    setState(() {});
  }

  TimeOfDay _parseTime(String iso) {
    final dt = DateTime.parse(iso).toLocal();
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  Future<void> _pickTime({required bool isDeparture}) async {
    final result =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (result != null) {
      setState(() => isDeparture ? departure = result : arrival = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingData != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: Text(isEditing ? "Edit Schedule" : "Add Schedule"),
      ),
      body: dropdowns.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDropdown(
                      "Bus",
                      selectedBus,
                      dropdowns["buses"]!,
                      (val) => setState(() => selectedBus = val),
                    ),
                    _buildDropdown(
                      "Route",
                      selectedRoute,
                      dropdowns["routes"]!,
                      (val) => setState(() => selectedRoute = val),
                    ),
                    ListTile(
                      title: Text(departure == null
                          ? "Pick Departure Time"
                          : "Departure: ${departure!.format(context)}"),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _pickTime(isDeparture: true),
                    ),
                    ListTile(
                      title: Text(arrival == null
                          ? "Pick Arrival Time"
                          : "Arrival: ${arrival!.format(context)}"),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _pickTime(isDeparture: false),
                    ),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: "Price (JOD)"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                      ),
                      onPressed: () async {
                        if ([selectedBus, selectedRoute, departure, arrival]
                            .contains(null)) {
                          return;
                        }

                        final price = double.tryParse(priceController.text);
                        if (price == null) return;

                        await ScheduleService.saveSchedule(
                          day: widget.day,
                          isEditing: isEditing,
                          existingId: widget.existingData?["id"],
                          busId: selectedBus!,
                          routeId: selectedRoute!,
                          dep: departure!,
                          arr: arrival!,
                          price: price,
                        );

                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        style: TextStyle(color: Colors.black),
                        "Save Schedule",
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown(String label, String? selected,
      List<Map<String, dynamic>> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: selected,
      items: items
          .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
              value: e["id"], child: Text(e["name"] ?? e["number"])))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }
}
