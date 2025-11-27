import 'package:flutter/material.dart';
import 'package:smartlink/models/connection.dart';
import 'package:smartlink/services/mock_data_service.dart';
import 'package:smartlink/widgets/thermostat_control.dart';
import 'package:smartlink/widgets/api_interaction.dart';

class DetailScreen extends StatefulWidget {
  final Connection connection;
  const DetailScreen({super.key, required this.connection});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Map<String, dynamic> metrics;

  @override
  void initState() {
    super.initState();
    metrics = MockDataService.fetchMetrics(widget.connection);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.connection;

    return Scaffold(
      appBar: AppBar(
        title: Text(c.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to dash',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => setState(() {
              metrics = MockDataService.fetchMetrics(c);
            }),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _infoCard(context, c),
            const SizedBox(height: 16),
            if (c.type == ConnectionType.api)
              ApiInteraction(connection: c, metrics: metrics)
            else
              ThermostatControl(connection: c, metrics: metrics),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, Connection c) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          runSpacing: 8,
          children: [
            _kv('Type', c.type.name),
            _kv('Endpoint', c.endpoint),
            _kv('Protocol', c.protocol),
            _kv('Key', c.apiKey.isEmpty ? '(none)' : '•' * 8),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
        Flexible(child: Text(v, textAlign: TextAlign.right)),
      ],
    );
  }
}
