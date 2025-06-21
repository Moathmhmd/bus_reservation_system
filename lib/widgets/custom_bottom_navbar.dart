import 'package:flutter/material.dart';
import 'package:bus_reservation_system/pages/user/user_home_page.dart';
import 'package:bus_reservation_system/pages/user/user_tickets_page.dart';
import 'package:bus_reservation_system/pages/user/user_history_page.dart';
import 'package:bus_reservation_system/pages/user/user_settings_page.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = UserHomePage();
        break;
      case 1:
        nextPage = const UserTicketsPage();
        break;
      case 2:
        nextPage = const UserHistoryPage();
        break;
      case 3:
        nextPage = const UserSettingsPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Colors.grey[100],
      indicatorColor: Colors.amber[200],
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onTap(context, index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(
            icon: Icon(Icons.confirmation_number), label: 'Tickets'),
        NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
