import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/providers/auth_providers.dart';
import '../../../features/device/providers/device_providers.dart';
import '../../widgets/primary_scaffold.dart';

class AddDeviceScreen extends ConsumerStatefulWidget {
  const AddDeviceScreen({super.key});

  static const routeName = 'add-device';

  @override
  ConsumerState<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends ConsumerState<AddDeviceScreen> {
  final _deviceIdController = TextEditingController();
  String? _status;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider);

    return PrimaryScaffold(
      title: 'Add Device',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Scan your Homiva device QR code or enter the ID manually.'),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Center(child: Text('QR Scanner placeholder')),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _deviceIdController,
            decoration: const InputDecoration(labelText: 'Device ID'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final deviceId = _deviceIdController.text.trim();
              if (deviceId.isEmpty || user == null) {
                return;
              }
              await ref.read(userDevicesRepositoryProvider).linkDevice(
                    userId: user.uid,
                    deviceId: deviceId,
                    role: 'owner',
                  );
              setState(() => _status = 'Device linked!');
              if (context.mounted) {
                context.go('/onboarding/complete');
              }
            },
            child: const Text('Link device'),
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!, style: const TextStyle(color: Colors.green)),
          ],
        ],
      ),
    );
  }
}
