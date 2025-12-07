import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'api/api_service.dart';
import 'auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment file
  await dotenv.load(fileName: ".env");

  // Initialize API service
  ApiService.instance.init();

  runApp(const HomeworkBusterApp());
}

class HomeworkBusterApp extends StatelessWidget {
  const HomeworkBusterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homework Buster',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
