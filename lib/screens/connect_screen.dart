import 'package:flutter/material.dart';
import 'package:smartlink/models/connection.dart';
import 'package:smartlink/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  ConnectionType _type = ConnectionType.api;
  final _nameCtrl = TextEditingController();
  final _endpointCtrl = TextEditingController();
  final _protocolCtrl = TextEditingController(text: 'https');
  final _apiKeyCtrl = TextEditingController();

  final _minTempCtrl = TextEditingController(text: '60');
  final _maxTempCtrl = TextEditingController(text: '80');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _endpointCtrl.dispose();
    _protocolCtrl.dispose();
    _apiKeyCtrl.dispose();
    _minTempCtrl.dispose();
    _maxTempCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    final connection = Connection(
      id: _uuid.v4(),
      name: _nameCtrl.text.trim(),
      type: _type,
      endpoint: _endpointCtrl.text.trim(),
      protocol: _protocolCtrl.text.trim(),
      apiKey: _apiKeyCtrl.text.trim(),
      minTemp: _type == ConnectionType.thermostat ? double.tryParse(_minTempCtrl.text) : null,
      maxTemp: _type == ConnectionType.thermostat ? double.tryParse(_maxTempCtrl.text) : null,
    );

    await StorageService.instance.addConnection(connection);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isThermo = _type == ConnectionType.thermostat;

    return Scaffold(
      appBar: AppBar(title: const Text('Connect')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<ConnectionType>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(
                        value: ConnectionType.api,
                        child: Text('API'),
                      ),
                      DropdownMenuItem(
                        value: ConnectionType.thermostat,
                        child: Text('Thermostat'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? ConnectionType.api),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _endpointCtrl,
                    decoration: const InputDecoration(labelText: 'Endpoint (URL or address)'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _protocolCtrl,
                    decoration: const InputDecoration(labelText: 'Protocol (e.g., https, mqtt)'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _apiKeyCtrl,
                    decoration: const InputDecoration(labelText: 'Key / Token'),
                  ),
                  if (isThermo) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minTempCtrl,
                            decoration: const InputDecoration(labelText: 'Min °F'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _maxTempCtrl,
                            decoration: const InputDecoration(labelText: 'Max °F'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Create'),
                      onPressed: _create,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
