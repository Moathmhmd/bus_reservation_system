import 'package:flutter/material.dart';

class HomeServices {
  static Future<DateTime?> pickDate(
      BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFFFD700), // yellow theme
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFFFFD700)),
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  static void validateAndSearch({
    required BuildContext context,
    required String from,
    required String to,
    required DateTime departureDate,
    required DateTime returnDate,
  }) {
    if (from == to) {
      _showSnackBar(context, 'Departure and destination cannot be the same.');
      return;
    }

    if (departureDate.isAfter(returnDate)) {
      _showSnackBar(context, 'Return date must be after the departure date.');
      return;
    }

    // Simulate search or navigate
    _showSnackBar(context, 'Searching for buses from $from to $to...');
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[900],
      ),
    );
  }
}
