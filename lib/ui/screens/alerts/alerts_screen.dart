import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/device/providers/device_providers.dart';
import '../../widgets/primary_scaffold.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  static const routeName = 'alerts';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceId = ref.watch(selectedDeviceIdProvider);
    final alertStream = ref.watch(activeAlertProvider);
    final alertsRepository = ref.watch(alertsRepositoryProvider);

    return PrimaryScaffold(
      title: 'Alerts',
      body: alertStream.when(
        data: (active) {
          if (deviceId.isEmpty) {
            return const Center(child: Text('Add a device to see alerts.'));
          }
          return StreamBuilder(
            stream: alertsRepository.streamAlerts(deviceId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final alertsList = snapshot.data ?? [];
              if (alertsList.isEmpty) {
                return const Center(child: Text('No alerts yet.'));
              }
              return ListView.builder(
                itemCount: alertsList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: ListTile(
                        leading: Icon(
                          active?.severity == 'critical'
                              ? Icons.warning
                              : active?.severity == 'warning'
                                  ? Icons.report_problem
                                  : Icons.notifications,
                          color: active?.severity == 'critical'
                              ? Colors.red
                              : active?.severity == 'warning'
                                  ? Colors.orange
                                  : Colors.blue,
                        ),
                        title: Text(active?.message ?? 'All systems normal.'),
                        subtitle: Text(active == null
                            ? 'No active alerts.'
                            : active.createdAt?.toLocal().toString() ?? ''),
                      ),
                    );
                  }
                  final alert = alertsList[index - 1];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        alert.severity == 'critical'
                            ? Icons.warning
                            : alert.severity == 'warning'
                                ? Icons.report_problem
                                : Icons.info,
                        color: alert.severity == 'critical'
                            ? Colors.red
                            : alert.severity == 'warning'
                                ? Colors.orange
                                : Colors.blue,
                      ),
                      title: Text(alert.message),
                      subtitle: Text(alert.createdAt?.toLocal().toString() ?? ''),
                      trailing: alert.clearedAt == null
                          ? TextButton(
                              onPressed: () => ref
                                  .read(alertsRepositoryProvider)
                                  .clearAlert(deviceId, alert.id),
                              child: const Text('Clear'),
                            )
                          : const Icon(Icons.check, color: Colors.green),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Failed to load alerts: $error')),
      ),
    );
  }
}
