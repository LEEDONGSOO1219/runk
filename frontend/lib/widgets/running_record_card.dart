import 'package:flutter/material.dart';

import '../models/running_record.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'app_cards.dart';

class RunningRecordCard extends StatelessWidget {
  const RunningRecordCard({
    required this.record,
    this.showMap = false,
    super.key,
  });

  final RunningRecord record;
  final bool showMap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  record.username.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.username,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record.runDate.toIso8601String().substring(0, 10),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '더보기',
                onPressed: () {},
                icon: Icon(Icons.more_horiz, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MapPreview(
            height: showMap ? 156 : 132,
            label: showMap ? '러닝 위치 기록' : '공유된 러닝',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Metric(
                label: '거리',
                value: '${record.distanceKm.toStringAsFixed(2)}km',
              ),
              _Metric(
                  label: '시간', value: formatDuration(record.durationSeconds)),
              _Metric(
                label: '페이스',
                value: '${formatPace(record.paceSecondsPerKm)}/km',
              ),
            ],
          ),
          if (record.memo != null && record.memo!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              record.memo!,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              _ActionPill(
                icon: Icons.favorite_border,
                label: '좋아요',
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _ActionPill(
                icon: Icons.chat_bubble_outline,
                label: '댓글',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.muted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
