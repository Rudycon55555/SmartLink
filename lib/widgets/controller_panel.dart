import 'package:flutter/material.dart';
import 'package:smartlink/services/controller_service.dart';

class ControllerPanel extends StatefulWidget {
  const ControllerPanel({super.key});

  @override
  State<ControllerPanel> createState() => _ControllerPanelState();
}

class _ControllerPanelState extends State<ControllerPanel> {
  final _commandCtrl = TextEditingController();
  String _result = '';

  Future<void> _send(String target) async {
    final cmd = _commandCtrl.text.trim();
    if (cmd.isEmpty) return;
    String res;
    switch (target) {
      case 'Google':
        res = await ControllerService.sendToGoogleHome(cmd);
        break;
      case 'Alexa':
        res = await ControllerService.sendToAlexa(cmd);
        break;
      case 'Siri':
        res = await ControllerService.sendToSiri(cmd);
        break;
      default:
        res = 'Unknown target';
    }
    setState(() => _result = res);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Smart Controller', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: _commandCtrl,
              decoration: const InputDecoration(
                labelText: 'Command',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                FilledButton(onPressed: () => _send('Google'), child: const Text('Google Home')),
                FilledButton(onPressed: () => _send('Alexa'), child: const Text('Alexa')),
                FilledButton(onPressed: () => _send('Siri'), child: const Text('Siri')),
              ],
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_result),
            ],
          ],
        ),
      ),
    );
  }
}
