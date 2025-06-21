import 'package:bus_reservation_system/Services/app_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusService {
  final _db = FirebaseFirestore.instance;

  // Fetch buses by the company associated with the logged-in user
  Stream<QuerySnapshot> fetchBusesByCompany() {
    final company = AppData().company;
    return _db
        .collection('buses')
        .where('company', isEqualTo: company)
        .snapshots();
  }

  // Add a new bus to Firestore
  Future<void> addBus(Map<String, dynamic> busData) async {
    await _db.collection('buses').add(busData);
  }

  // Update a bus's information
  Future<void> updateBus(String busId, Map<String, dynamic> busData) async {
    await _db.collection('buses').doc(busId).update(busData);
  }

  // Delete a bus from Firestore
  Future<void> deleteBus(String busId) async {
    await _db.collection('buses').doc(busId).delete();
  }

  // Fetch drivers for the company associated with the logged-in user
  Future<List<Map<String, dynamic>>> fetchDrivers() async {
    final company = AppData().company;
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'driver')
        .where('company', isEqualTo: company)
        .get();

    return snapshot.docs
        .map((doc) => {
              'name': doc['name'],
              'uid': doc.id,
            })
        .toList();
  }

}
