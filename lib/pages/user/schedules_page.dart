import 'package:bus_reservation_system/pages/user/SeatSelectionPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SchedulesPage extends StatefulWidget {
  final String start;
  final String end;
  final DateTime date;

  SchedulesPage({
    required this.start,
    required this.end,
    required this.date,
  });

  @override
  _SchedulesPageState createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
      QuerySnapshot snapshot = await _firestore.collection('schedules').get();

      List<Map<String, dynamic>> allMatches = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final departure = data['departureTime'] as String?;
        final routeId = data['routeId'];
        final status = data['status'];

        if (departure != null &&
            departure.startsWith(dateStr) &&
            status == "scheduled") {
          DocumentSnapshot routeDoc =
              await _firestore.collection('routes').doc(routeId).get();
          if (routeDoc.exists) {
            final routeData = routeDoc.data() as Map<String, dynamic>;
            final start = routeData['startLocation']['name'];
            final end = routeData['endLocation']['name'];

            if (start == widget.start && end == widget.end) {
              allMatches.add({
                ...data,
                'routeName': routeData['name'],
                'scheduleId': doc.id,
              });
            }
          }
        }
      }

      setState(() {
        schedules = allMatches;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching schedules: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Available Schedules'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return Card(
                    color: Colors.grey[100],
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  schedule['routeName'] ??
                                      'Route Name Not Available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey[800],
                                  ),
                                ),
                                SizedBox(height: 4),
                                if (schedule['price'] != null)
                                  Text(
                                    "Price: ${NumberFormat.simpleCurrency().format(schedule['price'])}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                SizedBox(height: 4),
                                Text(
                                  "Dep: ${DateFormat('yyyy-MM-dd – hh:mm a').format(DateTime.parse(schedule['departureTime']).toLocal())}",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Text(
                                  "Arr: ${DateFormat('yyyy-MM-dd – hh:mm a').format(DateTime.parse(schedule['arrivalTime']).toLocal())}",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Remaining Seats: ${schedule['remainingSeats'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: schedule['remainingSeats'] > 0
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: schedule['remainingSeats'] > 0
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SeatSelectionPage(
                                          scheduleId: schedule['scheduleId'],
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: schedule['remainingSeats'] > 0
                                  ? Colors.amber
                                  : Colors.grey[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            child: Text(
                              'Reserve',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
