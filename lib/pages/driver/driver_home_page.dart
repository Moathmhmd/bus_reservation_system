// driver_home_page.dart
import 'package:bus_reservation_system/Services/driver_schedule_service.dart';
import 'package:bus_reservation_system/pages/driver/map_page.dart';
import 'package:bus_reservation_system/pages/driver/trip_detail_page.dart';
import 'package:bus_reservation_system/widgets/schedule_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverHomePage extends StatelessWidget {
  final _scheduleService = DriverScheduleService();
  final driverId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Driver Dashboard"),
        backgroundColor: Colors.amber,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Text(
              "Welcome, Driver 👋",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 5, 20, 40),
            child: const Text(
              "Assigned Trips :",
              style: TextStyle(fontSize: 20),
            ),
          ),
          StreamBuilder(
            stream: _scheduleService.getUpcomingSchedulesForDriver(driverId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final schedules = snapshot.data!;
              if (schedules.isEmpty) {
                return Center(child: Text("No upcoming trips"));
              }

              return Container(
                decoration: BoxDecoration(color: Colors.amber, boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                      blurStyle: BlurStyle.outer)
                ]),
                child: SizedBox(
                  height: 250,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.88),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      return ScheduleCard(
                        schedule: schedule,
                        onTap: () {
                          if (schedule['status'] == 'In Progress') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MapPage(schedule: schedule),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TripDetailPage(schedule: schedule),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
