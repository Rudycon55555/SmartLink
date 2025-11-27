import 'dart:convert';

enum ConnectionType {
  api,
  thermostat,
}

class Connection {
  final String id;
  final String name;
  final ConnectionType type;

  // Common fields
  final String endpoint;
  final String protocol; // e.g., http, https, mqtt
  final String apiKey;

  // Thermostat-specific
  final double? minTemp;
  final double? maxTemp;

  const Connection({
    required this.id,
    required this.name,
    required this.type,
    required this.endpoint,
    required this.protocol,
    required this.apiKey,
    this.minTemp,
    this.maxTemp,
  });

  Connection copyWith({
    String? id,
    String? name,
    ConnectionType? type,
    String? endpoint,
    String? protocol,
    String? apiKey,
    double? minTemp,
    double? maxTemp,
  }) {
    return Connection(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      endpoint: endpoint ?? this.endpoint,
      protocol: protocol ?? this.protocol,
      apiKey: apiKey ?? this.apiKey,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'endpoint': endpoint,
      'protocol': protocol,
      'apiKey': apiKey,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
    };
  }

  factory Connection.fromMap(Map<String, dynamic> map) {
    return Connection(
      id: map['id'] as String,
      name: map['name'] as String,
      type: ConnectionType.values.firstWhere((e) => e.name == map['type']),
      endpoint: map['endpoint'] as String,
      protocol: map['protocol'] as String,
      apiKey: map['apiKey'] as String,
      minTemp: (map['minTemp'] as num?)?.toDouble(),
      maxTemp: (map['maxTemp'] as num?)?.toDouble(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Connection.fromJson(String source) =>
      Connection.fromMap(jsonDecode(source));
}
