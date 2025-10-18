import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/device_config.dart';
import '../../../features/device/providers/device_providers.dart';
import '../../../data/repositories/device_config_repository.dart';
import '../../widgets/primary_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const routeName = 'settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(selectedDeviceConfigProvider);

    final deviceId = ref.watch(selectedDeviceIdProvider);

    return PrimaryScaffold(
      title: 'Device Settings',
      body: deviceId.isEmpty
          ? const Center(child: Text('Add a device to manage its settings.'))
          : configAsync.when(
              data: (config) => _SettingsForm(config: config),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Failed to load settings: $error')),
            ),
    );
  }
}

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({required this.config});

  final DeviceConfig config;

  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  late double _threshold;
  late bool _lowWater;
  late bool _leak;
  late bool _overflow;
  late bool _tamper;

  @override
  void initState() {
    super.initState();
    _threshold = widget.config.lowWaterThresholdPct.toDouble();
    _lowWater = widget.config.alerts['lowWater'] ?? true;
    _leak = widget.config.alerts['leak'] ?? true;
    _overflow = widget.config.alerts['overflow'] ?? true;
    _tamper = widget.config.alerts['tamper'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final deviceId = ref.watch(selectedDeviceIdProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Low water threshold', style: Theme.of(context).textTheme.titleMedium),
                Slider(
                  min: 0,
                  max: 100,
                  value: _threshold,
                  onChanged: (value) => setState(() => _threshold = value),
                ),
                Text('Alert at ${_threshold.toStringAsFixed(0)}%'),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Low water alert'),
                  value: _lowWater,
                  onChanged: (value) => setState(() => _lowWater = value),
                ),
                SwitchListTile(
                  title: const Text('Leak alert'),
                  value: _leak,
                  onChanged: (value) => setState(() => _leak = value),
                ),
                SwitchListTile(
                  title: const Text('Overflow alert'),
                  value: _overflow,
                  onChanged: (value) => setState(() => _overflow = value),
                ),
                SwitchListTile(
                  title: const Text('Tamper alert'),
                  value: _tamper,
                  onChanged: (value) => setState(() => _tamper = value),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (deviceId.isEmpty) {
                      return;
                    }
                    final config = widget.config.copyWith(
                      lowWaterThresholdPct: _threshold.round(),
                      alerts: {
                        'lowWater': _lowWater,
                        'leak': _leak,
                        'overflow': _overflow,
                        'tamper': _tamper,
                      },
                    );
                    await ref.read(deviceConfigRepositoryProvider).updateConfig(deviceId, config);
                  },
                  child: const Text('Save changes'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Members', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                const Text('Invite members via phone or email (MVP placeholder).'),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: () {}, child: const Text('Invite member')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
