import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/device_analytics.dart';
import '../../services/firebase_service_registry.dart';

class AnalyticsRepository {
  AnalyticsRepository({required FirebaseServiceRegistry registry})
      : _firestore = registry.firestore;

  final FirebaseFirestore _firestore;

  Stream<List<DeviceAnalyticsDaily>> streamDaily(String deviceId) {
    final ref = _firestore.collection('devices').doc(deviceId).collection('analytics');
    return ref.snapshots().map((snapshot) => snapshot.docs.map(DeviceAnalyticsDaily.fromSnapshot).toList());
  }
}
