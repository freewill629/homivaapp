import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceCommand {
  const DeviceCommand({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    required this.createdBy,
    required this.status,
    this.ackAt,
    this.error,
  });

  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime? createdAt;
  final String? createdBy;
  final String status;
  final DateTime? ackAt;
  final String? error;

  factory DeviceCommand.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return DeviceCommand(
      id: snapshot.id,
      type: data['type'] as String? ?? 'UNKNOWN',
      payload: Map<String, dynamic>.from(data['payload'] as Map<String, dynamic>? ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] as String?,
      status: data['status'] as String? ?? 'queued',
      ackAt: (data['ackAt'] as Timestamp?)?.toDate(),
      error: data['error'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'payload': payload,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'status': status,
      'ackAt': ackAt != null ? Timestamp.fromDate(ackAt!) : null,
      'error': error,
    };
  }
}
