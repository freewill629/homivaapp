import 'package:fluttertoast/fluttertoast.dart';

import '../../../data/repositories/commands_repository.dart';
import '../../../data/repositories/device_config_repository.dart';
import '../../../domain/entities/device_command.dart';
import '../../../domain/entities/device_config.dart';

class DeviceCommandController {
  DeviceCommandController({
    required this.deviceId,
    required CommandsRepository commandsRepository,
    required DeviceConfigRepository configRepository,
  })  : _commandsRepository = commandsRepository,
        _configRepository = configRepository;

  final String deviceId;
  final CommandsRepository _commandsRepository;
  final DeviceConfigRepository _configRepository;

  Future<void> toggleManualPump({required bool isOn}) async {
    await _updateConfig((config) => config.copyWith(manualOverride: isOn));
    await _queueCommand(
      type: isOn ? 'MANUAL_PUMP_ON' : 'MANUAL_PUMP_OFF',
      payload: {
        'timeoutSeconds': isOn ? 300 : 0,
      },
    );
  }

  Future<void> toggleAutoControl(bool enabled) async {
    await _updateConfig(
      (config) => config.copyWith(autoControlEnabled: enabled),
    );
  }

  Future<void> toggleEmergencyMode(bool enabled) async {
    await _updateConfig(
      (config) => config.copyWith(emergencyMode: enabled, autoControlEnabled: !enabled),
    );
    await _queueCommand(
      type: enabled ? 'RESET_ALARMS' : 'SET_CONFIG',
      payload: {'emergencyMode': enabled},
    );
  }

  Future<void> _updateConfig(DeviceConfig Function(DeviceConfig) transform) async {
    final current = await _configRepository.stream(deviceId).first;
    final updated = transform(current);
    await _configRepository.updateConfig(deviceId, updated);
  }

  Future<void> _queueCommand({required String type, Map<String, dynamic>? payload}) async {
    final command = DeviceCommand(
      id: const Uuid().v4(),
      type: type,
      payload: payload ?? <String, dynamic>{},
      createdAt: DateTime.now(),
      createdBy: 'app',
      status: 'queued',
      ackAt: null,
      error: null,
    );
    try {
      await _commandsRepository.queueCommand(deviceId: deviceId, command: command);
      Fluttertoast.showToast(msg: 'Command sent');
    } catch (error) {
      Fluttertoast.showToast(msg: 'Failed to send command: $error');
    }
  }
}

class Uuid {
  const Uuid();

  String v4() {
    final millis = DateTime.now().microsecondsSinceEpoch;
    return millis.toRadixString(16);
  }
}
