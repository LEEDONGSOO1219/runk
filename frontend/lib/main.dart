import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'services/api_client.dart';
import 'theme/app_theme.dart';

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
  bool _isBootstrapping = true;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      apiClient.restoreSession(),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);
    if (mounted) {
      setState(() => _isBootstrapping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Runk',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(isDark: _isDarkMode),
      home: _isBootstrapping
          ? const SplashScreen()
          : apiClient.isLoggedIn
              ? MainShell(
                  apiClient: apiClient,
                  isDarkMode: _isDarkMode,
                  onThemeChanged: (value) {
                    setState(() => _isDarkMode = value);
                  },
                  onLogout: () {
                    apiClient.logout().then((_) {
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  },
                )
              : AuthScreen(
                  apiClient: apiClient,
                  onAuthenticated: () => setState(() {}),
                ),
    );
  }
}
