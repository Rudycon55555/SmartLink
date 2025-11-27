import 'package:flutter/material.dart';
import 'package:smartlink/services/storage_service.dart';
import 'package:smartlink/models/connection.dart';
import 'package:smartlink/widgets/connection_card.dart';
import 'detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Connection> _connections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await StorageService.instance.loadConnections();
    setState(() {
      _connections = list;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await StorageService.instance.deleteConnection(id);
    await _load();
  }

  void _open(Connection c) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DetailScreen(connection: c),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartLink Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_link),
            tooltip: 'Connect',
            onPressed: () => Navigator.of(context).pushNamed('/connect').then((_) => _load()),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _connections.isEmpty
              ? _emptyState(context)
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _connections.length,
                    itemBuilder: (context, i) {
                      final c = _connections[i];
                      return ConnectionCard(
                        connection: c,
                        onTap: () => _open(c),
                        onDelete: () => _delete(c.id),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link, size: 72),
            const SizedBox(height: 12),
            const Text(
              'No connections yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + link button to create your first API or thermostat connection.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create connection'),
              onPressed: () => Navigator.of(context).pushNamed('/connect').then((_) => _load()),
            ),
          ],
        ),
      ),
    );
  }
}
