import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/alerts_repository.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../../../data/repositories/commands_repository.dart';
import '../../../data/repositories/device_config_repository.dart';
import '../../../data/repositories/device_live_repository.dart';
import '../../../data/repositories/device_repository.dart';
import '../../../data/repositories/user_devices_repository.dart';
import '../../../domain/entities/device.dart';
import '../../../domain/entities/device_alert.dart';
import '../../../domain/entities/device_analytics.dart';
import '../../../domain/entities/device_config.dart';
import '../../../domain/entities/device_live_state.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../services/firebase_service_registry.dart';
import '../../auth/providers/auth_providers.dart';
import '../controllers/device_command_controller.dart';

final deviceRegistryProvider = Provider<FirebaseServiceRegistry>((ref) {
  return ref.watch(firebaseServiceRegistryProvider);
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepository(registry: ref.watch(deviceRegistryProvider));
});

final deviceLiveRepositoryProvider = Provider<DeviceLiveRepository>((ref) {
  return DeviceLiveRepository(registry: ref.watch(deviceRegistryProvider));
});

final deviceConfigRepositoryProvider = Provider<DeviceConfigRepository>((ref) {
  return DeviceConfigRepository(registry: ref.watch(deviceRegistryProvider));
});

final userDevicesRepositoryProvider = Provider<UserDevicesRepository>((ref) {
  return UserDevicesRepository(registry: ref.watch(deviceRegistryProvider));
});

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository(registry: ref.watch(deviceRegistryProvider));
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(registry: ref.watch(deviceRegistryProvider));
});

final selectedDeviceIdProvider = StateProvider<String>((ref) {
  final user = ref.watch(authUserProvider);
  if (user == null) {
    return '';
  }
  final links = ref.watch(userDeviceLinksProvider(user.uid)).maybeWhen(
        data: (value) => value,
        orElse: () => <UserDeviceLink>[],
      );
  return links.isNotEmpty ? links.first.deviceId : '';
});

final selectedDeviceProvider = StreamProvider<Device?>((ref) {
  final deviceId = ref.watch(selectedDeviceIdProvider);
  if (deviceId.isEmpty) {
    return Stream.value(null);
  }
  return ref.watch(deviceRepositoryProvider).watchDevice(deviceId).map((device) => device);
});

final selectedDeviceLiveProvider = StreamProvider<DeviceLiveState>((ref) {
  final deviceId = ref.watch(selectedDeviceIdProvider);
  if (deviceId.isEmpty) {
    return Stream.value(
      const DeviceLiveState(
        levelPct: 0,
        isPumping: false,
        qualityTds: null,
        leak: false,
        overflow: false,
        tamper: false,
        updatedAt: null,
      ),
    );
  }
  return ref.watch(deviceLiveRepositoryProvider).stream(deviceId);
});

final selectedDeviceConfigProvider = StreamProvider<DeviceConfig>((ref) {
  final deviceId = ref.watch(selectedDeviceIdProvider);
  if (deviceId.isEmpty) {
    return Stream.value(
      const DeviceConfig(
        autoControlEnabled: false,
        lowWaterThresholdPct: 20,
        emergencyMode: false,
        manualOverride: false,
        alerts: <String, bool>{},
        sampling: SamplingConfig(levelSecs: 30, qualitySecs: 60),
      ),
    );
  }
  return ref.watch(deviceConfigRepositoryProvider).stream(deviceId);
});

final activeAlertProvider = StreamProvider<DeviceAlert?>((ref) {
  final deviceId = ref.watch(selectedDeviceIdProvider);
  if (deviceId.isEmpty) {
    return Stream<DeviceAlert?>.value(null);
  }
  return ref.watch(alertsRepositoryProvider).streamAlerts(deviceId).map((alerts) {
    if (alerts.isEmpty) {
      return null;
    }
    alerts.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime(1970)) ?? 0);
    return alerts.firstWhere((element) => element.isActive, orElse: () => alerts.first);
  });
});

final analyticsProvider = StreamProvider<List<DeviceAnalyticsDaily>>((ref) {
  final deviceId = ref.watch(selectedDeviceIdProvider);
  if (deviceId.isEmpty) {
    return Stream.value(const <DeviceAnalyticsDaily>[]);
  }
  return ref.watch(analyticsRepositoryProvider).streamDaily(deviceId);
});

final userDeviceLinksProvider = StreamProvider.family<List<UserDeviceLink>, String>((ref, userId) {
  return ref.watch(userDevicesRepositoryProvider).streamLinks(userId);
});

final commandControllerProvider = Provider.family<DeviceCommandController, String>((ref, deviceId) {
  return DeviceCommandController(
    deviceId: deviceId,
    commandsRepository: ref.watch(commandsRepositoryProvider),
    configRepository: ref.watch(deviceConfigRepositoryProvider),
  );
});

final commandsRepositoryProvider = Provider<CommandsRepository>((ref) {
  return CommandsRepository(registry: ref.watch(deviceRegistryProvider));
});
