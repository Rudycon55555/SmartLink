import 'package:flutter/material.dart';
import 'package:smartlink/models/connection.dart';

class ConnectionCard extends StatelessWidget {
  final Connection connection;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConnectionCard({
    super.key,
    required this.connection,
    required this.onTap,
    required this.onDelete,
  });

  IconData get _icon {
    switch (connection.type) {
      case ConnectionType.api:
        return Icons.cloud_outlined;
      case ConnectionType.thermostat:
        return Icons.thermostat_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_icon, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      connection.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete',
                    onPressed: onDelete,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                connection.endpoint,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: FilledButton.tonal(
                  onPressed: onTap,
                  child: const Text('Open'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
