// schedule_service.dart
import 'package:bus_reservation_system/Services/app_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScheduleService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<Map<String, List<Map<String, dynamic>>>>
      fetchDropdownOptions() async {
    final company = AppData().company;

    final buses = await _db
        .collection("buses")
        .where("company", isEqualTo: company)
        .get();
    final routes = await _db
        .collection("routes")
        .where("company", isEqualTo: company)
        .get();
    final drivers = await _db
        .collection("users")
        .where("role", isEqualTo: "driver")
        .where("company", isEqualTo: company)
        .get();

    return {
      "buses": buses.docs
          .map((b) => {"id": b.id, "number": b["busNumber"]})
          .toList(),
      "routes":
          routes.docs.map((r) => {"id": r.id, "name": r["name"]}).toList(),
      "drivers":
          drivers.docs.map((d) => {"id": d.id, "name": d["name"]}).toList()
    };
  }

  static Stream<List<Map<String, dynamic>>> getSchedulesForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final company = AppData().company;

    return _db
        .collection("schedules")
        .where("company", isEqualTo: company)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) {
              final data = doc.data();
              final depTime =
                  DateTime.tryParse(data["departureTime"] ?? "")?.toLocal();
              if (depTime != null &&
                  depTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
                  depTime.isBefore(end)) {
                return {
                  "id": doc.id,
                  ...data,
                };
              }
              return null;
            })
            .whereType<Map<String, dynamic>>()
            .toList());
  }

  static Future<void> saveSchedule({
    required DateTime day,
    required bool isEditing,
    String? existingId,
    required String busId,
    required String routeId,
    required TimeOfDay dep,
    required TimeOfDay arr,
    required double price,
  }) async {
    final uid = _auth.currentUser!.uid;
    final companySnap = await _db.collection("users").doc(uid).get();
    final company = companySnap.data()!["company"];

    final busSnap = await _db.collection("buses").doc(busId).get();
    final routeSnap = await _db.collection("routes").doc(routeId).get();

    final totalSeats = busSnap.data()!["capacity"];
    final routeName = routeSnap.data()!["name"];
    final driverId = busSnap.data()!["driverId"];
    final driverName = busSnap.data()!["driverName"];

    final departureTime =
        DateTime(day.year, day.month, day.day, dep.hour, dep.minute).toUtc();
    final arrivalTime =
        DateTime(day.year, day.month, day.day, arr.hour, arr.minute).toUtc();

    final data = {
      "busId": busId,
      "busNumber": busSnap.data()!["busNumber"],
      "routeId": routeId,
      "routeName": routeName,
      "driverId": driverId,
      "driverName": driverName,
      "departureTime": departureTime.toIso8601String(),
      "arrivalTime": arrivalTime.toIso8601String(),
      "remainingSeats": totalSeats,
      "totalSeats": totalSeats,
      "company": company,
      "price": price,
      "status": "scheduled"
    };

    if (isEditing && existingId != null) {
      await _db.collection("schedules").doc(existingId).update(data);
    } else {
      await _db.collection("schedules").add(data);
    }
  }

  static Future<void> deleteSchedule(String id) async {
    await _db.collection("schedules").doc(id).delete();
  }

  static Future<void> cleanOldSchedules() async {
    final now = DateTime.now().toUtc();
    final oldSchedules = await _db
        .collection("schedules")
        .where("departureTime", isLessThan: now.toIso8601String())
        .get();

    for (final doc in oldSchedules.docs) {
      await doc.reference.delete();
    }
  }
}
