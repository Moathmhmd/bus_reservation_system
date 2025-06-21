import 'package:bus_reservation_system/widgets/ticket.dart';
import 'package:flutter/material.dart';

class TicketPage extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const TicketPage({Key? key, required this.ticketData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text('Your Ticket'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TicketView(ticketData: ticketData),
        ),
      ),
    );
  }
}
