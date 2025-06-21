import 'package:bus_reservation_system/widgets/seat_map.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bus_reservation_system/pages/driver/map_page.dart';
import 'package:bus_reservation_system/Services/driver_schedule_service.dart';
import 'package:url_launcher/url_launcher.dart';

class TripDetailPage extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final _scheduleService = DriverScheduleService();

  TripDetailPage({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final reservedSeats = List<int>.from(schedule['reservedSeats'] ?? []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Trip Details"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Route: ${schedule['routeName']}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Departure: ${_format(schedule['departureTime'])}"),
            Text("Arrival: ${_format(schedule['arrivalTime'])}"),
            Text(
                "Seats: ${schedule['remainingSeats']} / ${schedule['totalSeats']}"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text("Start Trip?"),
                    content: Text("Are you sure you want to start this trip?"),
                    actions: [
                      TextButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () => Navigator.pop(context)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200]),
                        child: Text("Confirm",
                            style: TextStyle(color: Colors.grey[800])),
                        onPressed: () async {
                          await _scheduleService.updateScheduleStatus(
                              schedule['id'], 'In Progress');
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Trip Started")));
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => MapPage(schedule: schedule)),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(150, 50),
                backgroundColor: Colors.green[600],
              ),
              child: Text("Start Trip",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(150, 50),
                  backgroundColor: Colors.green[600],
                ),
                onPressed: () async {
                  final route =
                      await _scheduleService.getRouteById(schedule['routeId']);
                  final start = route['startLocation'];
                  final end = route['endLocation'];

                  final Uri googleMapsUrl = Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&origin=${start['lat']},${start['lng']}&destination=${end['lat']},${end['lng']}',
                  );

                  if (await canLaunchUrl(googleMapsUrl)) {
                    await launchUrl(googleMapsUrl,
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  "View Route in Google Maps",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                )),
            const SizedBox(height: 20),
            Text("Reserved Seats Preview:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SeatMapWidget(reservedSeats: reservedSeats),
          ],
        ),
      ),
    );
  }

  String _format(String isoTime) {
    return DateFormat('yyyy-MM-dd – hh:mm a')
        .format(DateTime.parse(isoTime).toLocal());
  }
}
