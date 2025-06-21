import 'package:bus_reservation_system/pages/user/ticket_detail_page.dart';
import 'package:bus_reservation_system/widgets/custom_bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserTicketsPage extends StatelessWidget {
  const UserTicketsPage({super.key});

  Stream<List<Map<String, dynamic>>> _getLiveUserTickets() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('reservations')
        .where('UID', isEqualTo: uid)
        .snapshots()
        .asyncMap((reservationsSnapshot) async {
      List<Map<String, dynamic>> tickets = [];

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

        final routeDoc = await FirebaseFirestore.instance
            .collection('routes')
            .doc(routeId)
            .get();

        if (!routeDoc.exists) continue;

        final status = scheduleData['status']?.toString().toLowerCase();
        final arrivalStr = scheduleData['arrivalTime'];
        final arrivalTime = _parseDateTime(arrivalStr);

        // Filter out completed trips
        if (status == 'completed') {
          continue;
        }

        final routeData = routeDoc.data()!;

        tickets.add({
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
          'price': scheduleData['price']
        });
      }

      return tickets;
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
          title: const Text("My Tickets"),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _getLiveUserTickets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No tickets found."));
            }

            final tickets = snapshot.data!;
            return ListView.builder(
              itemCount: tickets.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                final route = ticket['route'];
                final status = ticket['status'];

                Color statusColor;
                IconData statusIcon;
                switch (status) {
                  case 'scheduled':
                    statusColor = Colors.green;
                    statusIcon = Icons.schedule;
                    break;
                  case 'In Progress':
                    statusColor = Colors.orange;
                    statusIcon = Icons.directions_bus;
                    break;
                  case 'Completed':
                    statusColor = Colors.red;
                    statusIcon = Icons.check_circle;
                    break;
                  default:
                    statusColor = Colors.grey;
                    statusIcon = Icons.info_outline;
                }

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketPage(ticketData: ticket),
                      ),
                    );
                  },
                  child: Card(
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
                          _ticketDetail("Bus Number", ticket['busNumber']),
                          _ticketDetail(
                              "Seat Number", ticket['seatNumber'].toString()),
                          _ticketDetail(
                              "Departure",
                              DateFormat('yyyy-MM-dd – hh:mm a').format(
                                  DateTime.parse(ticket['departureTime'])
                                      .toLocal())),
                          _ticketDetail(
                              "Arrival",
                              DateFormat('yyyy-MM-dd – hh:mm a').format(
                                  DateTime.parse(ticket['arrivalTime'])
                                      .toLocal())),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Chip(
                                avatar: Icon(statusIcon,
                                    size: 16, color: statusColor),
                                label: Text(status),
                                backgroundColor: statusColor.withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: const CustomNavBar(currentIndex: 1));
  }

  Widget _ticketDetail(String label, String value) {
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
