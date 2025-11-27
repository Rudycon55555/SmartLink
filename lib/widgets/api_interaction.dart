import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartlink/models/connection.dart';

class ApiInteraction extends StatefulWidget {
  final Connection connection;
  final Map<String, dynamic> metrics;
  const ApiInteraction({super.key, required this.connection, required this.metrics});

  @override
  State<ApiInteraction> createState() => _ApiInteractionState();
}

class _ApiInteractionState extends State<ApiInteraction> {
  final _payloadCtrl = TextEditingController();
  String _response = '';
  bool _loading = false;

  @override
  void dispose() {
    _payloadCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _loading = true;
      _response = '';
    });

    try {
      final headers = <String, String>{};
      if (widget.connection.apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${widget.connection.apiKey}';
      }

      final uri = Uri.parse(widget.connection.endpoint);
      http.Response res;

      // Simple logic: POST if payload given, otherwise GET.
      if (_payloadCtrl.text.trim().isEmpty) {
        res = await http.get(uri, headers: headers);
      } else {
        res = await http.post(uri, headers: headers, body: _payloadCtrl.text.trim());
      }

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
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('API Preview', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _metricRow('Latency (ms)', '${m['latencyMs']}'),
            _metricRow('Success rate', '${((m['successRate'] ?? 0.0) * 100).toStringAsFixed(1)}%'),
            _metricRow('Throughput', '${m['throughput']} req/min'),
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
                icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
                label: const Text('Send'),
                onPressed: _loading ? null : _send,
              ),
            ),
            const SizedBox(height: 12),
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

  Widget _metricRow(String k, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
        Flexible(child: Text(v, textAlign: TextAlign.right)),
      ],
    );
  }
}
