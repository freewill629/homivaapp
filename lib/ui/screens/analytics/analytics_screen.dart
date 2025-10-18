import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/device_analytics.dart';
import '../../../features/device/providers/device_providers.dart';
import '../../widgets/primary_scaffold.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  static const routeName = 'analytics';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);

    return PrimaryScaffold(
      title: 'Usage Analytics',
      body: analytics.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('No analytics yet.')); 
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AnalyticsCard(
                title: 'Daily Water Usage',
                data: data,
                valueSelector: (item) => item.usedLiters,
                unit: 'L',
                color: charts.MaterialPalette.blue.shadeDefault,
              ),
              _AnalyticsCard(
                title: 'Average Level',
                data: data,
                valueSelector: (item) => item.avgLevelPct,
                unit: '%',
                color: charts.MaterialPalette.cyan.shadeDefault,
              ),
              _AnalyticsCard(
                title: 'Pump Cycles',
                data: data,
                valueSelector: (item) => item.pumpCycles.toDouble(),
                unit: 'cycles',
                color: charts.MaterialPalette.deepOrange.shadeDefault,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Failed to load analytics: $error')),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.data,
    required this.valueSelector,
    required this.unit,
    required this.color,
  });

  final String title;
  final List<DeviceAnalyticsDaily> data;
  final double Function(DeviceAnalyticsDaily) valueSelector;
  final String unit;
  final charts.Color color;

  @override
  Widget build(BuildContext context) {
    final chartData = [
      charts.Series<DeviceAnalyticsDaily, DateTime>(
        id: title,
        domainFn: (datum, _) => datum.date,
        measureFn: (datum, _) => valueSelector(datum),
        colorFn: (_, __) => color,
        data: data,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: charts.TimeSeriesChart(chartData, animate: true)),
            const SizedBox(height: 8),
            Text('Last value: ${valueSelector(data.last).toStringAsFixed(1)} $unit'),
          ],
        ),
      ),
    );
  }
}
