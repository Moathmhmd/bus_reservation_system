import 'package:bus_reservation_system/widgets/custom_elevated_Button.dart';
import 'package:bus_reservation_system/widgets/seat_map_user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PassengerFormPage.dart';

class SeatSelectionPage extends StatefulWidget {
  final String scheduleId;

  const SeatSelectionPage({required this.scheduleId, Key? key})
      : super(key: key);

  @override
  _SeatSelectionPageState createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  Set<int> reservedSeats = {};
  int? selectedSeat;

  @override
  void initState() {
    super.initState();
    fetchReservedSeats();
  }

  Future<void> fetchReservedSeats() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('schedules')
          .doc(widget.scheduleId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final List<dynamic> reserved = data['reservedSeats'] ?? [];
        setState(() {
          reservedSeats = reserved.map((e) => e as int).toSet();
        });
      }
    } catch (e) {
      print('Error fetching reserved seats: $e');
    }
  }

  void confirmReservation() {
    if (selectedSeat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a seat.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerFormPage(
          scheduleId: widget.scheduleId,
          seatNumber: selectedSeat!,
        ),
      ),
    );
  }

  void onSeatSelected(int seatNumber) {
    setState(() {
      selectedSeat = (selectedSeat == seatNumber) ? null : seatNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.amber,
          centerTitle: true,
          title: const Text('Select Your Seat')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(height: 17),
              Expanded(
                child: Center(
                  child: SeatMapUserWidget(
                    reservedSeats: reservedSeats,
                    selectedSeat: selectedSeat,
                    onSeatSelected: onSeatSelected,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomElevatedButton(
                text: 'Confirm Reservation',
                onPressed: confirmReservation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
