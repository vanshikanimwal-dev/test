import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart'; // Make sure this is imported if you use it in _setupLogging
import 'package:provider/provider.dart'; // Ensure this is imported for MultiProvider
import 'package:ferrero_asset_management/provider/data_provider.dart'; // Ensure this is imported
import 'package:ferrero_asset_management/screens/auth/login_page.dart'; // Assuming this is your starting page
import 'package:logging/logging.dart';
void _setupLogging() {
  print('DEBUG: _setupLogging called. (From main.dart)'); // Direct print for setup confirmation
  Logger.root.level = Level.ALL; // Set to ALL to capture FINE, INFO, WARNING, SEVERE
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name} [${record.loggerName}] ${record.time}: ${record.message}');
    if (record.error != null) {
      // ignore: avoid_print
      print('  ERROR: ${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('  STACKTRACE: ${record.stackTrace}');
    }
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _setupLogging(); // Call logging setup here
  print('DEBUG: main() started and _setupLogging complete. (From main.dart)'); // Direct print
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        // Add any other providers here
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ferrero Asset Management',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(), // Your starting screen
    );
  }
}