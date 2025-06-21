import 'package:cloud_firestore/cloud_firestore.dart';

class DriverScheduleService {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getUpcomingSchedulesForDriver(
      String driverId) {
    return _firestore
        .collection('schedules')
        .where('driverId', isEqualTo: driverId)
        // .where('status', whereIn: ['scheduled', 'In Progress'])
        .snapshots()
        .asyncMap((snapshot) async {
      final schedules = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        data['id'] = doc.id;

        final routeRef = data['routeId'];
        if (routeRef != null) {
          final routeSnap =
              await _firestore.collection('routes').doc(routeRef).get();
          final routeData = routeSnap.data();
          if (routeData != null) {
            data['route'] = {
              'startLocation': routeData['startLocation'],
              'endLocation': routeData['endLocation'],
              'stops': routeData['stops'] ?? [],
              'estimatedDuration': routeData['estimatedDuration'],
            };
          }
        }

        return data;
      }).toList());

      schedules.sort((a, b) {
        if (a['status'] == 'In Progress' && b['status'] != 'In Progress') {
          return -1;
        } else if (a['status'] != 'In Progress' &&
            b['status'] == 'In Progress') {
          return 1;
        }
        return 0;
      });

      return schedules;
    });
  }

  Future<void> updateScheduleStatus(String scheduleId, String newStatus) {
    return _firestore
        .collection('schedules')
        .doc(scheduleId)
        .update({'status': newStatus});
  }

  Future<Map<String, dynamic>> getRouteById(String routeId) async {
    final doc = await FirebaseFirestore.instance
        .collection('routes')
        .doc(routeId)
        .get();
    return doc.data()!;
  }

  Future<Map<String, dynamic>> getDriverInfo(String driverId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(driverId)
        .get();
    return doc.data()!;
  }
}
