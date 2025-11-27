import 'package:flutter/material.dart';
import 'package:smartlink/models/connection.dart';

class ThermostatControl extends StatefulWidget {
  final Connection connection;
  final Map<String, dynamic> metrics;
  const ThermostatControl({super.key, required this.connection, required this.metrics});

  @override
  State<ThermostatControl> createState() => _ThermostatControlState();
}

class _ThermostatControlState extends State<ThermostatControl> {
  late double _target;
  String _mode = 'Auto';

  @override
  void initState() {
    super.initState();
    _target = (widget.metrics['targetTemp'] as num?)?.toDouble() ?? 72.0;
    _mode = widget.metrics['mode']?.toString() ?? 'Auto';
  }

  @override
  Widget build(BuildContext context) {
    final minT = widget.connection.minTemp ?? 60;
    final maxT = widget.connection.maxTemp ?? 80;
    final current = (widget.metrics['currentTemp'] as num?)?.toDouble() ?? 72.0;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thermostat', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _simpleGauge(context, current, minT, maxT),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Mode'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _mode,
                  items: const [
                    DropdownMenuItem(value: 'Heat', child: Text('Heat')),
                    DropdownMenuItem(value: 'Cool', child: Text('Cool')),
                    DropdownMenuItem(value: 'Auto', child: Text('Auto')),
                  ],
                  onChanged: (v) => setState(() => _mode = v ?? 'Auto'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Target °F'),
                Expanded(
                  child: Slider(
                    value: _target,
                    min: minT,
                    max: maxT,
                    divisions: (maxT - minT).round(),
                    label: _target.toStringAsFixed(0),
                    onChanged: (v) => setState(() => _target = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Apply'),
                onPressed: () {
                  // Here you'd send the target/mode to the thermostat endpoint.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Applied: $_mode, ${_target.toStringAsFixed(0)}°F')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleGauge(BuildContext context, double value, double min, double max) {
    final pct = ((value - min) / (max - min)).clamp(0.0, 1.0);
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          LayoutBuilder(builder: (ctx, c) {
            final w = c.maxWidth * pct;
            return Container(
              width: w,
              height: 14,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${value.toStringAsFixed(1)} °F',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
