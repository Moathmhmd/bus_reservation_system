import 'package:bus_reservation_system/pages/driver/driver_home_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bus_reservation_system/Services/driver_schedule_service.dart';

class MapPage extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final _scheduleService = DriverScheduleService();

  MapPage({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final route = schedule['route'];
    final start = route['startLocation'];
    final end = route['endLocation'];

    final startLatLng = '${start['lat']},${start['lng']}';
    final endLatLng = '${end['lat']},${end['lng']}';

    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$startLatLng&destination=$endLatLng',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Route Map"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/map.jpg', fit: BoxFit.contain),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              icon: Icon(
                Icons.map,
                color: Colors.white,
              ),
              label: Text(
                "Open Route in Google Maps",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(150, 50),
                backgroundColor: Colors.green[600],
              ),
              onPressed: () async {
                if (await canLaunchUrl(googleMapsUrl)) {
                  await launchUrl(googleMapsUrl,
                      mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not open Google Maps")),
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(150, 50),
                backgroundColor: Colors.grey[600],
              ),
              icon: Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text("Finish Trip?"),
                    content: Text("Are you sure you want to Finish this trip?"),
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
                              schedule['id'], 'Completed');
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Trip Completed")));
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => DriverHomePage()),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
              label: Text(
                "Finish Trip",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
