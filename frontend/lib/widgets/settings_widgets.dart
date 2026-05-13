import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SettingRow extends StatelessWidget {
  const SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 0,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.muted, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class SettingSwitchRow extends StatelessWidget {
  const SettingSwitchRow({
    required this.title,
    required this.value,
    this.onChanged,
    super.key,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      activeThumbColor: AppColors.green,
      activeTrackColor: const Color(0x5539A66F),
      inactiveThumbColor: AppColors.muted,
      inactiveTrackColor: AppColors.surfaceHigh,
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w800,
        ),
      ),
      onChanged: onChanged ?? (_) {},
    );
  }
}
