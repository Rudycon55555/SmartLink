import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/models/connection.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  late SharedPreferences _prefs;
  static const _keyConnections = 'smartlink_connections_v1';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Connection>> loadConnections() async {
    final raw = _prefs.getString(_keyConnections);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Connection.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveConnections(List<Connection> connections) async {
    final encoded = jsonEncode(connections.map((c) => c.toMap()).toList());
    await _prefs.setString(_keyConnections, encoded);
  }

  Future<void> addConnection(Connection connection) async {
    final all = await loadConnections();
    all.add(connection);
    await saveConnections(all);
  }

  Future<void> updateConnection(Connection connection) async {
    final all = await loadConnections();
    final idx = all.indexWhere((c) => c.id == connection.id);
    if (idx != -1) {
      all[idx] = connection;
      await saveConnections(all);
    }
  }

  Future<void> deleteConnection(String id) async {
    final all = await loadConnections();
    all.removeWhere((c) => c.id == id);
    await saveConnections(all);
  }
}
