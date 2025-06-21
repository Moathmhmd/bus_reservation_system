import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationService {
  final FirebaseFirestore _firestore;

  ReservationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<bool> confirmSingleSeatReservation({
    required String scheduleId,
    required int selectedSeat,
  }) async {
    final scheduleRef = _firestore.collection('schedules').doc(scheduleId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(scheduleRef);

        if (!snapshot.exists) {
          throw Exception("Schedule does not exist.");
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final existingSeats = (data['reservedSeats'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toSet() ??
            <int>{};

        if (existingSeats.contains(selectedSeat)) {
          throw Exception("Selected seat is already reserved.");
        }

        final updatedSeats = existingSeats..add(selectedSeat);
        final remainingSeats = (data['remainingSeats'] ?? 45) as int;

        transaction.update(scheduleRef, {
          'reservedSeats': updatedSeats.toList(),
          'remainingSeats': remainingSeats - 1,
        });
      });

      return true;
    } catch (e) {
      print('Reservation error: $e');
      rethrow;
    }
  }
}
