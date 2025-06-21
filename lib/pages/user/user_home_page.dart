import 'package:bus_reservation_system/pages/user/schedules_page.dart';
import 'package:bus_reservation_system/widgets/custom_bottom_navbar.dart';
import 'package:bus_reservation_system/widgets/custom_elevated_Button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> routes = [];
  String? selectedStart;
  String? selectedEnd;
  DateTime selectedDate = DateTime.now();
  String _userName = "User"; // Default value

  Future<void> fetchRoutes() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('routes').get();
      setState(() {
        routes = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            "routeId": data["routeId"],
            "routeName": data["routeName"],
            "startLocation": data["startLocation"],
            "endLocation": data["endLocation"]
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching routes: $e");
    }
  }

  List<String> getStartLocations() {
    return routes
        .map((r) => r['startLocation']['name'] as String)
        .toSet()
        .toList();
  }

  List<String> getFilteredEndLocations() {
    if (selectedStart == null) return [];
    return routes
        .where((r) => r['startLocation']['name'] == selectedStart)
        .map((r) => r['endLocation']['name'] as String)
        .toSet()
        .toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _fetchUserName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get();

    if (userDoc.exists && userDoc.data() != null) {
      final userData = userDoc.data()!;
      final nameFromDB = userData['name'] as String?;
      if (nameFromDB != null) {
        setState(() {
          _userName = nameFromDB;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRoutes();
    _fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    final endLocations = getFilteredEndLocations();

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text("Bus Reservation"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
              tooltip: 'Sign Out',
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Good Morning",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600])),
                        Text("Welcome, $_userName",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600))
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 30),
                Text("Book your trip",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          dropdownColor: Colors.white,
                          value: selectedStart,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            labelText: 'From',
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: getStartLocations()
                              .map((loc) => DropdownMenuItem(
                                  value: loc, child: Text(loc)))
                              .toList(),
                          onChanged: (val) => setState(() {
                            selectedStart = val;
                            selectedEnd = null;
                          }),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          dropdownColor: Colors.white,
                          value: selectedEnd,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            labelText: 'To',
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: endLocations
                              .map((loc) => DropdownMenuItem(
                                  value: loc, child: Text(loc)))
                              .toList(),
                          onChanged: (val) => setState(() => selectedEnd = val),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                  text: "${selectedDate.toLocal()}"
                                      .split(' ')[0]),
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                labelText: 'Select Date',
                                suffixIcon: Icon(Icons.calendar_today),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomElevatedButton(
                          onPressed:
                              (selectedStart != null && selectedEnd != null)
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SchedulesPage(
                                            start: selectedStart!,
                                            end: selectedEnd!,
                                            date: selectedDate,
                                          ),
                                        ),
                                      );
                                    }
                                  : () {},
                          text: "Search Schedules",
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomNavBar(currentIndex: 0));
  }
}
