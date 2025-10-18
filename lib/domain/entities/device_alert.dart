import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceAlert {
  const DeviceAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.createdAt,
    required this.levelPct,
    this.clearedAt,
  });

  final String id;
  final String type;
  final String severity;
  final String message;
  final DateTime? createdAt;
  final int? levelPct;
  final DateTime? clearedAt;

  bool get isActive => clearedAt == null;

  factory DeviceAlert.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return DeviceAlert(
      id: snapshot.id,
      type: data['type'] as String? ?? 'UNKNOWN',
      severity: data['severity'] as String? ?? 'info',
      message: data['message'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      levelPct: (data['levelPct'] as num?)?.toInt(),
      clearedAt: (data['clearedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'severity': severity,
      'message': message,
      'createdAt': createdAt,
      'levelPct': levelPct,
      'clearedAt': clearedAt,
    };
  }
}
