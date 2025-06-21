import 'package:flutter/material.dart';

class SeatMapWidget extends StatelessWidget {
  final List<int> reservedSeats;

  const SeatMapWidget({required this.reservedSeats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDriverRow(),
        ..._generateSeatRows(),
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

  List<Widget> _generateSeatRows() {
    List<Widget> rows = [];

    List<List<int>> rowConfig = [
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

    for (var config in rowConfig) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: config.map((num) {
          if (num == 0) return _space();
          if (num == -1) return _door();
          return _seatBox(num, reservedSeats.contains(num));
        }).toList(),
      ));
    }

    return rows;
  }

  Widget _seatBox(int number, bool isReserved) {
    return Container(
      width: 30,
      height: 30,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isReserved ? Colors.red[600] : Colors.green[800],
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text('$number',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  Widget _space() {
    return Container(width: 40, height: 40);
  }

  Widget _driverBox() {
    return Container(
      width: 30,
      height: 30,
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
      width: 30,
      height: 30,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(child: Text("Door", style: TextStyle(fontSize: 10))),
    );
  }
}
