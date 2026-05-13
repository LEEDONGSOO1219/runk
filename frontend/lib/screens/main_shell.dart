import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../theme/app_theme.dart';
import 'feed_screen.dart';
import 'friends_screen.dart';
import 'home_screen.dart';
import 'records_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    required this.apiClient,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onLogout,
    super.key,
  });

  final ApiClient apiClient;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(apiClient: widget.apiClient),
      const FriendsScreen(),
      FeedScreen(apiClient: widget.apiClient),
      RecordsScreen(apiClient: widget.apiClient),
      SettingsScreen(
        apiClient: widget.apiClient,
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 68,
            backgroundColor: AppColors.background,
            indicatorColor: AppColors.surfaceHigh,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                color: selected ? AppColors.text : AppColors.muted,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: selected ? AppColors.text : AppColors.muted,
                size: 23,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _index,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_outlined),
                label: '홈',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people_outline),
                label: '친구',
              ),
              NavigationDestination(
                icon: Icon(Icons.article_outlined),
                selectedIcon: Icon(Icons.article_outlined),
                label: '피드',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart_outlined),
                label: '기록',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_outlined),
                label: '설정',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
