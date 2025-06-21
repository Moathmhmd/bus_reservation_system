import 'package:bus_reservation_system/Services/admin_schedule_service.dart';
import 'package:bus_reservation_system/pages/admin/schdule_form_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminSchedulePage extends StatefulWidget {
  const AdminSchedulePage({super.key});

  @override
  State<AdminSchedulePage> createState() => _AdminSchedulePageState();
}

class _AdminSchedulePageState extends State<AdminSchedulePage> {
  DateTime selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEE, MMM d, yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Schedule Management"),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[300],
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.calendar_today),
              label: Text("Selected: $formattedDate"),
              onPressed: _pickDate,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder(
              stream: ScheduleService.getSchedulesForDay(selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Schedules found."));
                }
                final schedules = snapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...schedules.map((s) => GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScheduleFormPage(
                                day: selectedDate,
                                existingData: s,
                              ),
                            ),
                          ),
                          child: Card(
                            color: Colors.grey[100],
                            child: ListTile(
                              title:
                                  Text("${s["busNumber"]} - ${s["routeName"]}"),
                              subtitle: Text(
                                  "${_formatTime(s["departureTime"])} - ${_formatTime(s["arrivalTime"])} | "
                                  "Seats: ${s["remainingSeats"]}/${s["totalSeats"]} | Price: \$${s["price"] ?? 'N/A'}"),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await ScheduleService.deleteSchedule(s["id"]);
                                },
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 80)
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScheduleFormPage(day: selectedDate),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTime(String isoTime) {
    final time = DateTime.parse(isoTime).toLocal();
    return TimeOfDay(hour: time.hour, minute: time.minute).format(context);
  }
}
