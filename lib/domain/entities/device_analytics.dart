import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceAnalyticsDaily {
  const DeviceAnalyticsDaily({
    required this.id,
    required this.usedLiters,
    required this.avgLevelPct,
    required this.pumpCycles,
    required this.date,
  });

  final String id;
  final double usedLiters;
  final double avgLevelPct;
  final int pumpCycles;
  final DateTime date;

  factory DeviceAnalyticsDaily.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return DeviceAnalyticsDaily(
      id: snapshot.id,
      usedLiters: (data['usedLiters'] as num?)?.toDouble() ?? 0,
      avgLevelPct: (data['avgLevelPct'] as num?)?.toDouble() ?? 0,
      pumpCycles: (data['pumpCycles'] as num?)?.toInt() ?? 0,
      date: _parseDate(snapshot.id),
    );
  }

  static DateTime _parseDate(String id) {
    if (id.startsWith('daily_') && id.length >= 15) {
      final dateStr = id.substring(6, 14);
      final year = int.tryParse(dateStr.substring(0, 4)) ?? 0;
      final month = int.tryParse(dateStr.substring(4, 6)) ?? 1;
      final day = int.tryParse(dateStr.substring(6, 8)) ?? 1;
      return DateTime(year, month, day);
    }
    return DateTime.now();
  }
}
