import 'package:bus_reservation_system/Services/reservation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatefulWidget {
  final String scheduleId;
  final int seatNumber;
  final Map<String, dynamic> passengerInfo;

  const PaymentPage({
    required this.scheduleId,
    required this.seatNumber,
    required this.passengerInfo,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  final ReservationService _reservationService = ReservationService();

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _reservationService.confirmSingleSeatReservation(
        scheduleId: widget.scheduleId,
        selectedSeat: widget.seatNumber,
      );

      await FirebaseFirestore.instance.collection('reservations').add({
        'scheduleId': widget.scheduleId,
        'seatNumber': widget.seatNumber,
        'passengerInfo': widget.passengerInfo,
        'cardName': _nameController.text.trim(),
        'cardNumber': _cardNumberController.text.trim(),
        'expiry': _expiryController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'UID': FirebaseAuth.instance.currentUser!.uid,
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Payment Successful"),
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
          content: Text("Failed to process reservation: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCardInputField(String label, TextEditingController controller,
      {bool obscure = false, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? "Required" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Payment"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Credit Card Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8)
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildCardInputField(
                            "Cardholder Name", _nameController),
                        _buildCardInputField(
                            "Card Number", _cardNumberController,
                            type: TextInputType.number),
                        Row(
                          children: [
                            Expanded(
                                child: _buildCardInputField(
                                    "Expiry (MM/YY)", _expiryController,
                                    type: TextInputType.datetime)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildCardInputField(
                                    "CVV", _cvvController,
                                    obscure: true, type: TextInputType.number)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _handlePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                    ),
                    child: const Text(
                      "Pay & Confirm",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
