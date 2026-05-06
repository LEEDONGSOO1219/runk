import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/feed_screen.dart';
import 'services/api_client.dart';

void main() {
  runApp(const RunkApp());
}

class RunkApp extends StatefulWidget {
  const RunkApp({super.key});

  @override
  State<RunkApp> createState() => _RunkAppState();
}

class _RunkAppState extends State<RunkApp> {
  final ApiClient apiClient = ApiClient();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '런크',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E7A5B)),
        useMaterial3: true,
      ),
      home: apiClient.isLoggedIn
          ? FeedScreen(apiClient: apiClient)
          : AuthScreen(
              apiClient: apiClient,
              onAuthenticated: () => setState(() {}),
            ),
    );
  }
}
