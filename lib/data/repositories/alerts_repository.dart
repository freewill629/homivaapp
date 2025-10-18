import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/device_alert.dart';
import '../../services/firebase_service_registry.dart';

class AlertsRepository {
  AlertsRepository({required FirebaseServiceRegistry registry})
      : _firestore = registry.firestore;

  final FirebaseFirestore _firestore;

  Stream<List<DeviceAlert>> streamAlerts(String deviceId) {
    final ref = _firestore.collection('devices').doc(deviceId).collection('alerts').orderBy('createdAt', descending: true);
    return ref.snapshots().map((snapshot) => snapshot.docs.map(DeviceAlert.fromSnapshot).toList());
  }

  Future<void> clearAlert(String deviceId, String alertId) {
    final ref = _firestore.collection('devices').doc(deviceId).collection('alerts').doc(alertId);
    return ref.update({'clearedAt': FieldValue.serverTimestamp()});
  }
}
