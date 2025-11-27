import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartlink/models/connection.dart';
import 'package:fl_chart/fl_chart.dart';

class ApiInteraction extends StatefulWidget {
  final Connection connection;
  final Map<String, dynamic> metrics;
  const ApiInteraction({super.key, required this.connection, required this.metrics});

  @override
  State<ApiInteraction> createState() => _ApiInteractionState();
}

class _ApiInteractionState extends State<ApiInteraction> {
  final _payloadCtrl = TextEditingController();
  final _headersCtrl = TextEditingController();
  String _response = '';
  bool _loading = false;
  List<double> _latencyHistory = [];

  Future<void> _send() async {
    setState(() {
      _loading = true;
      _response = '';
    });

    try {
      final headers = <String, String>{};
      if (_headersCtrl.text.trim().isNotEmpty) {
        for (var line in _headersCtrl.text.split('\n')) {
          final parts = line.split(':');
          if (parts.length == 2) {
            headers[parts[0].trim()] = parts[1].trim();
          }
        }
      }
      if (widget.connection.apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${widget.connection.apiKey}';
      }

      final uri = Uri.parse(widget.connection.endpoint);
      final start = DateTime.now();
      http.Response res;

      if (_payloadCtrl.text.trim().isEmpty) {
        res = await http.get(uri, headers: headers);
      } else {
        res = await http.post(uri, headers: headers, body: _payloadCtrl.text.trim());
      }
      final latency = DateTime.now().difference(start).inMilliseconds.toDouble();
      _latencyHistory.add(latency);

      setState(() {
        _response = 'Status: ${res.statusCode}\n\n${res.body}';
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.metrics;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('API Interaction', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: _headersCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Custom Headers (key: value per line)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _payloadCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Payload (optional for POST)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: _loading ? const CircularProgressIndicator(strokeWidth: 2) : const Icon(Icons.send),
                label: const Text('Send'),
                onPressed: _loading ? null : _send,
              ),
            ),
            const SizedBox(height: 12),
            if (_latencyHistory.isNotEmpty) _latencyChart(),
            if (_response.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_response),
              ),
          ],
        ),
      ),
    );
  }

  Widget _latencyChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _latencyHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
