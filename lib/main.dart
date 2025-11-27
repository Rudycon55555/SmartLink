import 'package:flutter/material.dart';
import 'package:smartlink/screens/dashboard_screen.dart';
import 'package:smartlink/screens/connect_screen.dart';
import 'package:smartlink/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  runApp(const SmartLinkApp());
}

class SmartLinkApp extends StatelessWidget {
  const SmartLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14.5),
      ),
    );

    return MaterialApp(
      title: 'SmartLink',
      theme: theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/connect': (context) => const ConnectScreen(),
      },
    );
  }
}
