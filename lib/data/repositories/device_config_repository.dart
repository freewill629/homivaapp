import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/device_config.dart';
import '../../services/firebase_service_registry.dart';

class DeviceConfigRepository {
  DeviceConfigRepository({required FirebaseServiceRegistry registry})
      : _firestore = registry.firestore;

  final FirebaseFirestore _firestore;

  Stream<DeviceConfig> stream(String deviceId) {
    final ref = _firestore.doc('devices/$deviceId/config/current').withConverter<DeviceConfig>(
          fromFirestore: (snapshot, _) => DeviceConfig.fromMap(snapshot.data()),
          toFirestore: (config, _) => config.toMap(),
        );
    return ref.snapshots().map((snapshot) => snapshot.data() ?? const DeviceConfig(
          autoControlEnabled: false,
          lowWaterThresholdPct: 20,
          emergencyMode: false,
          manualOverride: false,
          alerts: const <String, bool>{},
          sampling: SamplingConfig(levelSecs: 30, qualitySecs: 60),
        ));
  }

  Future<void> updateConfig(String deviceId, DeviceConfig config) {
    final ref = _firestore.doc('devices/$deviceId/config/current');
    return ref.set(config.toMap(), SetOptions(merge: true));
  }
}
