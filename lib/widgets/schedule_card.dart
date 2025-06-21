import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleCard extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final VoidCallback onTap;

  const ScheduleCard({required this.schedule, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: schedule["status"] == "Completed" ? () {} : onTap,
      child: Card(
        color: Colors.grey[100],
        margin: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${schedule['routeName']}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Dep: ${DateFormat('yyyy-MM-dd – hh:mm a').format(DateTime.parse(schedule['departureTime']).toLocal())}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Arr: ${DateFormat('yyyy-MM-dd – hh:mm a').format(DateTime.parse(schedule['arrivalTime']).toLocal())}",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Seats: ${schedule['remainingSeats']} / ${schedule['totalSeats']}",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Chip(
                  label: Text(schedule['status']),
                  backgroundColor: schedule['status'] == 'scheduled'
                      ? Colors.grey
                      : schedule['status'] == 'In Progress'
                          ? Colors.green
                          : Colors.red,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
