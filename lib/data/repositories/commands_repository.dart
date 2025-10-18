import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/device_command.dart';
import '../../services/firebase_service_registry.dart';

class CommandsRepository {
  CommandsRepository({required FirebaseServiceRegistry registry})
      : _firestore = registry.firestore;

  final FirebaseFirestore _firestore;

  Future<void> queueCommand({
    required String deviceId,
    required DeviceCommand command,
  }) async {
    final ref = _firestore.collection('devices').doc(deviceId).collection('commands').doc(command.id);
    await ref.set(command.toMap());
  }

  Stream<List<DeviceCommand>> streamCommands(String deviceId) {
    final ref = _firestore.collection('devices').doc(deviceId).collection('commands');
    return ref.snapshots().map((snapshot) => snapshot.docs.map(DeviceCommand.fromSnapshot).toList());
  }
}
