import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';
import '../../services/firebase_service_registry.dart';

class UserDevicesRepository {
  UserDevicesRepository({required FirebaseServiceRegistry registry})
      : _firestore = registry.firestore;

  final FirebaseFirestore _firestore;

  Stream<List<UserDeviceLink>> streamLinks(String userId) {
    final ref = _firestore.collection('userDevices').doc(userId).collection('links');
    return ref.snapshots().map((snapshot) => snapshot.docs.map(UserDeviceLink.fromSnapshot).toList());
  }

  Future<void> linkDevice({
    required String userId,
    required String deviceId,
    required String role,
  }) {
    final ref = _firestore.collection('userDevices').doc(userId).collection('links').doc(deviceId);
    return ref.set({
      'role': role,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }
}
