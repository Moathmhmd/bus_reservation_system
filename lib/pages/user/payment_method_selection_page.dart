import 'package:bus_reservation_system/Services/reservation_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'payment_page.dart';

class PaymentMethodSelectionPage extends StatelessWidget {
  final String scheduleId;
  final int seatNumber;
  final Map<String, dynamic> passengerInfo;

  PaymentMethodSelectionPage({
    required this.scheduleId,
    required this.seatNumber,
    required this.passengerInfo,
    Key? key,
  }) : super(key: key);

  final ReservationService _reservationService = ReservationService();

  void _handleCashPayment(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Confirm Cash Payment"),
        content: const Text(
            "Do you want to confirm your reservation and pay with cash?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog

              try {
                await _reservationService.confirmSingleSeatReservation(
                  scheduleId: scheduleId,
                  selectedSeat: seatNumber,
                );

                await FirebaseFirestore.instance
                    .collection('reservations')
                    .add({
                  'scheduleId': scheduleId,
                  'seatNumber': seatNumber,
                  'passengerInfo': passengerInfo,
                  'paymentMethod': 'Cash',
                  'timestamp': FieldValue.serverTimestamp(),
                  'UID': FirebaseAuth.instance.currentUser!.uid,
                });

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text("Reservation Confirmed"),
                    content: const Text("Your reservation has been confirmed."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                            ..pop()
                            ..pop()
                            ..pop()
                            ..pop()
                            ..pop();
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Error"),
                    content: Text("Failed to confirm reservation: $e"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            },
            icon: const Icon(Icons.check_circle),
            label: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 30),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 70),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          shadowColor: Colors.amberAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Choose Payment Method"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionButton(
              context: context,
              label: "Credit Card",
              icon: Icons.credit_card,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentPage(
                      scheduleId: scheduleId,
                      seatNumber: seatNumber,
                      passengerInfo: passengerInfo,
                    ),
                  ),
                );
              },
            ),
            _buildOptionButton(
              context: context,
              label: "Cash",
              icon: Icons.money,
              onTap: () => _handleCashPayment(context),
            ),
          ],
        ),
      ),
    );
  }
}
