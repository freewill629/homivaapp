import 'package:firebase_database/firebase_database.dart';

import '../../domain/entities/device_live_state.dart';
import '../../services/firebase_service_registry.dart';

class DeviceLiveRepository {
  DeviceLiveRepository({required FirebaseServiceRegistry registry})
      : _database = registry.realtimeDatabase;

  final FirebaseDatabase _database;

  Stream<DeviceLiveState> stream(String deviceId) {
    final ref = _database.ref('live/$deviceId');
    return ref.onValue.map((event) => DeviceLiveState.fromMap(event.snapshot.value as Map<dynamic, dynamic>?));
  }
}
