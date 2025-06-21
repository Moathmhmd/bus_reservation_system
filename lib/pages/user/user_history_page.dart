import 'package:bus_reservation_system/widgets/custom_bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserHistoryPage extends StatelessWidget {
  const UserHistoryPage({super.key});

  Stream<List<Map<String, dynamic>>> _getCompletedTrips() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('reservations')
        .where('UID', isEqualTo: uid)
        .snapshots()
        .asyncMap((reservationsSnapshot) async {
      List<Map<String, dynamic>> history = [];

      for (var reservation in reservationsSnapshot.docs) {
        final data = reservation.data();
        final scheduleId = data['scheduleId'];
        final seatNumber = data['seatNumber'];

        final scheduleDoc = await FirebaseFirestore.instance
            .collection('schedules')
            .doc(scheduleId)
            .get();

        if (!scheduleDoc.exists) continue;

        final scheduleData = scheduleDoc.data()!;
        final routeId = scheduleData['routeId'];
        final status = scheduleData['status']?.toString().toLowerCase();

        // Only show completed trips
        if (status != 'completed') continue;

        final routeDoc = await FirebaseFirestore.instance
            .collection('routes')
            .doc(routeId)
            .get();

        if (!routeDoc.exists) continue;

        final routeData = routeDoc.data()!;

        history.add({
          'seatNumber': seatNumber,
          'status': scheduleData['status'],
          'departureTime': scheduleData['departureTime'],
          'arrivalTime': scheduleData['arrivalTime'],
          'busNumber': scheduleData['busNumber'],
          'route': {
            'start': routeData['startLocation']['name'],
            'end': routeData['endLocation']['name'],
          },
          'passengerName': data['passengerInfo']['name'],
          'price': scheduleData['price'],
        });
      }

      return history;
    });
  }

  DateTime? _parseDateTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;

    try {
      return DateFormat("yyyy-MM-dd HH:mm").parse(timeStr);
    } catch (_) {
      try {
        return DateFormat("yyyy-MM-dd").parse(timeStr);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text("Trip History"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getCompletedTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No completed trips yet."));
          }

          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final trip = history[index];
              final route = trip['route'];

              return Card(
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.alt_route, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${route['start']} → ${route['end']}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _tripDetail("Bus Number", trip['busNumber']),
                      _tripDetail("Seat Number", trip['seatNumber'].toString()),
                      _tripDetail(
                        "Departure",
                        DateFormat('yyyy-MM-dd – hh:mm a').format(
                            _parseDateTime(trip['departureTime'])!.toLocal()),
                      ),
                      _tripDetail(
                        "Arrival",
                        DateFormat('yyyy-MM-dd – hh:mm a').format(
                            _parseDateTime(trip['arrivalTime'])!.toLocal()),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.check_circle,
                                size: 16, color: Colors.red),
                            label: const Text("Completed"),
                            backgroundColor: Colors.red.withOpacity(0.1),
                            labelStyle: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }

  Widget _tripDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
