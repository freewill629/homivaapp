class DeviceLiveState {
  const DeviceLiveState({
    required this.levelPct,
    required this.isPumping,
    required this.qualityTds,
    required this.leak,
    required this.overflow,
    required this.tamper,
    required this.updatedAt,
  });

  final int levelPct;
  final bool isPumping;
  final double? qualityTds;
  final bool leak;
  final bool overflow;
  final bool tamper;
  final DateTime? updatedAt;

  factory DeviceLiveState.fromMap(Map<dynamic, dynamic>? data) {
    final map = data ?? <dynamic, dynamic>{};
    return DeviceLiveState(
      levelPct: (map['levelPct'] as num?)?.toInt() ?? 0,
      isPumping: map['isPumping'] as bool? ?? false,
      qualityTds: (map['qualityTDS'] as num?)?.toDouble(),
      leak: map['leak'] as bool? ?? false,
      overflow: map['overflow'] as bool? ?? false,
      tamper: map['tamper'] as bool? ?? false,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['updatedAt'] as int?) ?? 0)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'levelPct': levelPct,
      'isPumping': isPumping,
      'qualityTDS': qualityTds,
      'leak': leak,
      'overflow': overflow,
      'tamper': tamper,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }
}
