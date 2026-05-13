import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/app_cards.dart';
import '../widgets/settings_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
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
  Widget build(BuildContext context) {
    final user = apiClient.currentUser;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          key: ValueKey(isDarkMode),
          padding: const EdgeInsets.fromLTRB(22, 34, 22, 32),
          children: [
            Text(
              '설정',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '러닝 경험과 계정을 관리해요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 28),
            const SectionHeader(title: '계정'),
            AppCard(
              child: Column(
                children: [
                  SettingRow(
                    icon: Icons.person_outline,
                    title: user?.username ?? '러너',
                    subtitle: user?.email ?? '로그인 정보 없음',
                  ),
                  const Divider(height: 26),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.logout, color: AppColors.muted),
                    title: Text(
                      '로그아웃',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onTap: onLogout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const SectionHeader(title: '화면'),
            AppCard(
              child: Column(
                children: [
                  SettingSwitchRow(
                    title: '다크 모드',
                    value: isDarkMode,
                    onChanged: onThemeChanged,
                  ),
                  SettingRow(
                    icon: isDarkMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    title: isDarkMode ? '다크 테마 사용 중' : '라이트 테마 사용 중',
                    subtitle: isDarkMode ? '차분한 야간 러닝 화면' : '밝고 일반적인 앱 화면',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const SectionHeader(title: '러닝 설정'),
            AppCard(
              child: Column(
                children: [
                  SettingSwitchRow(title: '자동 일시정지', value: true),
                  SettingSwitchRow(title: '음성 안내', value: false),
                  const Divider(height: 26),
                  const SettingRow(
                    icon: Icons.straighten,
                    title: '거리 단위',
                    subtitle: '킬로미터(km)',
                  ),
                  const SettingRow(
                    icon: Icons.location_on_outlined,
                    title: '위치 권한',
                    subtitle: '러닝 시작 시 요청',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const SectionHeader(title: '공개 범위'),
            AppCard(
              child: Column(
                children: [
                  SettingSwitchRow(title: '피드 공개', value: true),
                  SettingSwitchRow(title: '친구에게 기록 공개', value: true),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const SectionHeader(title: '보안'),
            const AppCard(
              child: Column(
                children: [
                  SettingRow(
                    icon: Icons.lock_outline,
                    title: '비밀번호 변경',
                    subtitle: '준비 중',
                  ),
                  SettingRow(
                    icon: Icons.verified_user_outlined,
                    title: '로그인 상태',
                    subtitle: 'JWT 인증 사용 중',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const SectionHeader(title: '앱 정보'),
            const AppCard(
              child: Column(
                children: [
                  SettingRow(
                    icon: Icons.info_outline,
                    title: '버전',
                    subtitle: '0.1.0',
                  ),
                  SettingRow(
                    icon: Icons.privacy_tip_outlined,
                    title: '개인정보 처리방침',
                    subtitle: '포트폴리오 MVP',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
