import 'package:flutter/material.dart';

class UserHeader extends StatelessWidget {
  final String userName;
  final String greeting;

  const UserHeader({
    super.key,
    required this.userName,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber[800],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://storage.googleapis.com/a1aa/image/SEBmRgkXKPS1RZZYjT9LHUTVG1I2ywq4Y5Jg92UU0M4.jpg',
                ),
                radius: 24,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting, style: const TextStyle(color: Colors.white)),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.notifications, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Securely Book your Bus Ticket',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
