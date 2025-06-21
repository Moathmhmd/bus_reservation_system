import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus_reservation_system/Services/app_data.dart';

class RouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getRoutesStream() {
    return _firestore
        .collection('routes')
        .where('company', isEqualTo: AppData().company)
        .snapshots();
  }

  Future<void> addOrUpdateRoute(Map<String, dynamic> routeData,
      {String? docId}) async {
    if (docId != null) {
      await _firestore.collection('routes').doc(docId).update(routeData);
    } else {
      await _firestore.collection('routes').add(routeData);
    }
  }

  Future<void> deleteRoute(String docId) async {
    await _firestore.collection('routes').doc(docId).delete();
  }
}
