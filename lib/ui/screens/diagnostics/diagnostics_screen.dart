import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/providers/auth_providers.dart';
import '../../../features/device/providers/device_providers.dart';
import '../../../firebase_options.dart';
import '../../widgets/primary_scaffold.dart';

class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  static const routeName = 'diagnostics';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final deviceId = ref.watch(selectedDeviceIdProvider);
    final device = ref.watch(selectedDeviceProvider);
    final live = ref.watch(selectedDeviceLiveProvider);

    return PrimaryScaffold(
      title: 'Diagnostics',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Firebase app ID: ${DefaultFirebaseOptions.currentPlatform.appId}'),
            const SizedBox(height: 8),
            Text('User ID: ${user?.uid ?? '-'}'),
            const SizedBox(height: 8),
            Text('Selected device: $deviceId'),
            const SizedBox(height: 16),
            device.when(
              data: (value) => value == null
                  ? const Text('No device linked')
                  : Text('Device status: ${value.status}, last seen ${value.lastSeenAt ?? '-'}'),
              loading: () => const Text('Loading device...'),
              error: (error, stackTrace) => Text('Device error: $error'),
            ),
            const SizedBox(height: 16),
            live.when(
              data: (value) => Text('Live level: ${value.levelPct}%, pump ${value.isPumping ? 'on' : 'off'}'),
              loading: () => const Text('Loading live data...'),
              error: (error, stackTrace) => Text('Live error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
