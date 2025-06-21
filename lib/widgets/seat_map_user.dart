import 'package:flutter/material.dart';

class SeatMapUserWidget extends StatelessWidget {
  final Set<int> reservedSeats;
  final int? selectedSeat;
  final Function(int) onSeatSelected;

  const SeatMapUserWidget({
    required this.reservedSeats,
    required this.selectedSeat,
    required this.onSeatSelected,
  });

  @override
  Widget build(BuildContext context) {
    List<List<int>> seatLayout = [
      [1, 2, 0, 3, 4],
      [5, 6, 0, 7, 8],
      [9, 10, 0, 11, 12],
      [13, 14, 0, 15, 16],
      [17, 18, 0, 19, 20],
      [21, 22, 0, 0, -1],
      [23, 24, 0, 0, -1],
      [25, 26, 0, 27, 28],
      [29, 30, 0, 31, 32],
      [33, 34, 0, 35, 36],
      [37, 38, 0, 39, 40],
      [41, 42, 0, 43, 44],
      [45, 46, 47, 48, 49],
    ];

    return Column(
      children: [
        _buildDriverRow(),
        ...seatLayout.map((row) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((seatNumber) {
                if (seatNumber == 0) return _space();
                if (seatNumber == -1) return _door();
                return _seatBox(seatNumber);
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildDriverRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _driverBox(),
        _space(),
        _space(),
        _space(),
        _door(),
      ],
    );
  }

  Widget _seatBox(int number) {
    bool isReserved = reservedSeats.contains(number);
    bool isSelected = selectedSeat == number;

    Color seatColor;
    if (isReserved) {
      seatColor = Colors.red;
    } else if (isSelected) {
      seatColor = Colors.blue;
    } else {
      seatColor = Colors.green;
    }

    return GestureDetector(
      onTap: isReserved
          ? null
          : () {
              onSeatSelected(number);
            },
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: seatColor,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _space() {
    return Container(width: 47, height: 47);
  }

  Widget _driverBox() {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(Icons.person, color: Colors.white, size: 20),
    );
  }

  Widget _door() {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          "Door",
          style: TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}
