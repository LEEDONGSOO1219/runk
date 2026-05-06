import 'package:flutter/material.dart';

import '../services/api_client.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    final user = apiClient.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 36,
              child: Text(user?.username.substring(0, 1).toUpperCase() ?? 'R'),
            ),
            const SizedBox(height: 16),
            Text(
              user?.username ?? '러너',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(user?.email ?? ''),
            const SizedBox(height: 24),
            const Text('MVP 프로필: 계정 정보만 표시합니다.'),
          ],
        ),
      ),
    );
  }
}
