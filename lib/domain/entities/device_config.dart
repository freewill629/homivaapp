class DeviceConfig {
  const DeviceConfig({
    required this.autoControlEnabled,
    required this.lowWaterThresholdPct,
    required this.emergencyMode,
    required this.manualOverride,
    required this.alerts,
    required this.sampling,
  });

  final bool autoControlEnabled;
  final int lowWaterThresholdPct;
  final bool emergencyMode;
  final bool manualOverride;
  final Map<String, bool> alerts;
  final SamplingConfig sampling;

  DeviceConfig copyWith({
    bool? autoControlEnabled,
    int? lowWaterThresholdPct,
    bool? emergencyMode,
    bool? manualOverride,
    Map<String, bool>? alerts,
    SamplingConfig? sampling,
  }) {
    return DeviceConfig(
      autoControlEnabled: autoControlEnabled ?? this.autoControlEnabled,
      lowWaterThresholdPct: lowWaterThresholdPct ?? this.lowWaterThresholdPct,
      emergencyMode: emergencyMode ?? this.emergencyMode,
      manualOverride: manualOverride ?? this.manualOverride,
      alerts: alerts != null ? Map<String, bool>.from(alerts) : Map<String, bool>.from(this.alerts),
      sampling: sampling ?? this.sampling,
    );
  }

  factory DeviceConfig.fromMap(Map<String, dynamic>? map) {
    final data = map ?? <String, dynamic>{};
    return DeviceConfig(
      autoControlEnabled: data['autoControlEnabled'] as bool? ?? false,
      lowWaterThresholdPct: data['lowWaterThresholdPct'] as int? ?? 20,
      emergencyMode: data['emergencyMode'] as bool? ?? false,
      manualOverride: data['manualOverride'] as bool? ?? false,
      alerts: Map<String, bool>.from(data['alerts'] as Map<String, dynamic>? ?? {}),
      sampling: SamplingConfig.fromMap(data['sampling'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'autoControlEnabled': autoControlEnabled,
      'lowWaterThresholdPct': lowWaterThresholdPct,
      'emergencyMode': emergencyMode,
      'manualOverride': manualOverride,
      'alerts': alerts,
      'sampling': sampling.toMap(),
    };
  }
}

class SamplingConfig {
  const SamplingConfig({
    required this.levelSecs,
    required this.qualitySecs,
  });

  final int levelSecs;
  final int qualitySecs;

  factory SamplingConfig.fromMap(Map<String, dynamic>? map) {
    final data = map ?? <String, dynamic>{};
    return SamplingConfig(
      levelSecs: data['levelSecs'] as int? ?? 30,
      qualitySecs: data['qualitySecs'] as int? ?? 60,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'levelSecs': levelSecs,
      'qualitySecs': qualitySecs,
    };
  }
}
