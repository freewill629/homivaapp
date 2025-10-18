import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/device.dart';
import '../../services/firebase_service_registry.dart';

class DeviceRepository {
  DeviceRepository({required FirebaseServiceRegistry registry})
      : _firestore = registry.firestore;

  final FirebaseFirestore _firestore;

  Stream<Device> watchDevice(String deviceId) {
    final ref = _firestore.doc('devices/$deviceId');
    return ref.snapshots().map(Device.fromFirestore);
  }

  Future<List<Device>> loadDevicesByIds(List<String> deviceIds) async {
    if (deviceIds.isEmpty) {
      return <Device>[];
    }
    final chunks = <List<String>>[];
    const chunkSize = 10;
    for (var i = 0; i < deviceIds.length; i += chunkSize) {
      chunks.add(deviceIds.sublist(i, i + chunkSize > deviceIds.length ? deviceIds.length : i + chunkSize));
    }
    final devices = <Device>[];
    for (final chunk in chunks) {
      final snapshot = await _firestore.collection('devices').where(FieldPath.documentId, whereIn: chunk).get();
      devices.addAll(snapshot.docs.map(Device.fromFirestore));
    }
    return devices;
  }
}
