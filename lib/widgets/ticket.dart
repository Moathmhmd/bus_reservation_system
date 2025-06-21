import 'package:flutter/material.dart';
import 'package:ticket_widget/ticket_widget.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';

class TicketView extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const TicketView({Key? key, required this.ticketData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final route = ticketData['route'];
    final departureTime = _formatDate(ticketData['departureTime']);
    final arrivalTime = _formatDate(ticketData['arrivalTime']);
    final status = ticketData['status'] ?? 'Scheduled';
    final price = ticketData['price']?.toString() ?? 'N/A';
    final seat = ticketData['seatNumber'].toString();
    final bus = ticketData['busNumber'].toString();
    final passenger = ticketData['passengerName'] ?? 'Passenger';
    final date = DateFormat('MMM d, yyyy')
        .format(DateTime.parse(ticketData['departureTime']).toLocal());

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

    return Center(
      child: TicketWidget(
        width: 400,
        height: 700,
        isCornerRounded: true,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bus Ticket',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Chip(
                  avatar: Icon(statusIcon, size: 16, color: statusColor),
                  label: Text(status),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Top Row: Passenger & Date
            _rowLine('Passenger', passenger, 'Date', date),
            const SizedBox(height: 8),

            // Bus & Seat
            _rowLine('Bus', bus, 'Seat', seat),
            const SizedBox(height: 8),

            // From & To
            _rowLine('From', route['start'], 'To', route['end']),
            const SizedBox(height: 8),

            // Departure & Arrival
            _rowLine('Departure', departureTime, 'Arrival', arrivalTime),
            const SizedBox(height: 35),

            // Price
            Text(
              'Price: \$${price}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),

            const SizedBox(height: 24),

            const Divider(thickness: 2),
            const Spacer(),

            // Barcode
            Center(
              child: Column(
                children: [
                  const Text(
                    'Scan at Boarding',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  BarcodeWidget(
                    data: 'TICKET-${bus}-${seat}',
                    barcode: Barcode.code128(),
                    width: 250,
                    height: 70,
                    drawText: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final date = DateTime.parse(raw).toLocal();
      return DateFormat('hh:mm a').format(date);
    } catch (_) {
      return raw;
    }
  }

  Widget _rowLine(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(
          child: _labeledText(label1, value1),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _labeledText(label2, value2, alignRight: true),
        ),
      ],
    );
  }

  Widget _labeledText(String label, String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
