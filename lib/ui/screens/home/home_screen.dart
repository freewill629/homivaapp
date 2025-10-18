import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/device_config.dart';
import '../../../domain/entities/device_live_state.dart';
import '../../../features/auth/providers/auth_providers.dart';
import '../../../features/device/providers/device_providers.dart';
import '../../widgets/level_gauge.dart';
import '../../widgets/primary_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAsync = ref.watch(selectedDeviceLiveProvider);
    final configAsync = ref.watch(selectedDeviceConfigProvider);
    final deviceAsync = ref.watch(selectedDeviceProvider);
    final deviceId = ref.watch(selectedDeviceIdProvider);

    return PrimaryScaffold(
      title: 'Your Tank',
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(selectedDeviceLiveProvider);
          ref.invalidate(selectedDeviceConfigProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
          children: [
            deviceAsync.when(
              data: (device) {
                if (device == null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('No device linked', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          const Text('Add your Homiva tank to see live water level and alerts.'),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(device.isOnline ? Icons.circle : Icons.circle_outlined,
                            color: device.isOnline ? Colors.green : Colors.grey, size: 12),
                        const SizedBox(width: 6),
                        Text(device.isOnline ? 'Online' : 'Offline'),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text('Failed to load device: $error'),
            ),
            const SizedBox(height: 24),
            if (deviceId.isEmpty) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.go('/onboarding/add'),
                child: const Text('Add device'),
              ),
            ] else ...[
              liveAsync.when(
                data: (live) => _HomeLiveCard(live: live),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Text('Failed to load live data: $error'),
              ),
              const SizedBox(height: 24),
              configAsync.when(
                data: (config) => _QuickActions(config: config),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Text('Failed to load config: $error'),
              ),
              const SizedBox(height: 24),
              const _AlertStrip(),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeLiveCard extends StatelessWidget {
  const _HomeLiveCard({required this.live});

  final DeviceLiveState live;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LevelGauge(levelPct: live.levelPct),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatusChip(icon: Icons.water_drop, label: '${live.levelPct} %'),
                _StatusChip(
                  icon: live.isPumping ? Icons.flash_on : Icons.flash_off,
                  label: live.isPumping ? 'Pumping' : 'Idle',
                ),
                _StatusChip(
                  icon: Icons.science,
                  label: live.qualityTds != null ? 'TDS ${live.qualityTds!.toStringAsFixed(0)} ppm' : 'TDS sensor offline',
                ),
                if (live.updatedAt != null)
                  _StatusChip(
                    icon: Icons.schedule,
                    label: 'Updated ${DateFormat.Hm().format(live.updatedAt!.toLocal())}',
                  ),
              ],
            ),
            if (live.leak || live.overflow || live.tamper)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (live.leak) _WarningBanner(text: 'Leak detected. Turn off pump and check connections.'),
                    if (live.overflow) _WarningBanner(text: 'Overflow detected. Check tank outlet.'),
                    if (live.tamper) _WarningBanner(text: 'Tamper detected. Investigate immediately.'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.config});

  final DeviceConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(selectedDeviceLiveProvider).maybeWhen(data: (value) => value, orElse: () => null);
    final deviceId = ref.watch(selectedDeviceIdProvider);
    final commands = ref.watch(commandControllerProvider(deviceId));

    final isManualDisabled = (live?.leak ?? false) || (live?.overflow ?? false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: isManualDisabled
                      ? null
                      : () async {
                          final isCurrentlyOn = live?.isPumping ?? false;
                          if (!isCurrentlyOn) {
                            final confirmed = await showModalBottomSheet<bool>(
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Turn on manual pump?', style: Theme.of(context).textTheme.titleLarge),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Manual control will run the pump for up to 5 minutes. Make sure the tank is safe before continuing.',
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          OutlinedButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('Turn on'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            if (confirmed != true) {
                              return;
                            }
                          }
                          await commands.toggleManualPump(isOn: !isCurrentlyOn);
                        },
                  icon: const Icon(Icons.power_settings_new),
                  label: Text((live?.isPumping ?? false) ? 'Stop pump' : 'Manual pump on'),
                ),
                FilledButton.tonal(
                  onPressed: () => commands.toggleAutoControl(!config.autoControlEnabled),
                  child: Text(config.autoControlEnabled ? 'Disable auto control' : 'Enable auto control'),
                ),
                OutlinedButton(
                  onPressed: () => commands.toggleEmergencyMode(!config.emergencyMode),
                  child: Text(config.emergencyMode ? 'Exit emergency' : 'Emergency mode'),
                ),
              ],
            ),
            if (isManualDisabled)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Manual pump disabled while leak/overflow active.',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AlertStrip extends ConsumerWidget {
  const _AlertStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(activeAlertProvider);
    return alerts.when(
      data: (alert) {
        if (alert == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.verified, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(child: Text('All systems normal.')),
                ],
              ),
            ),
          );
        }
        return Card(
          color: _alertColor(alert.severity),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alert.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Text('Failed to load alerts: $error'),
    );
  }

  Color _alertColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.redAccent;
      case 'warning':
        return Colors.orangeAccent;
      default:
        return Colors.blueAccent;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.redAccent)),
    );
  }
}
