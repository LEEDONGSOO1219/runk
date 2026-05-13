import 'package:flutter/material.dart';

import '../models/running_record.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_cards.dart';
import 'record_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<RunningRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _recordsFuture = widget.apiClient.fetchMyRecords();
  }

  Future<void> _openRecordForm() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecordFormScreen(apiClient: widget.apiClient),
      ),
    );
    if (saved == true && mounted) {
      setState(_refresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<RunningRecord>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            final records = snapshot.data ?? [];
            final todayKey = DateTime.now().toIso8601String().substring(0, 10);
            final todayRecord = records
                .where(
                  (record) =>
                      record.runDate.toIso8601String().substring(0, 10) ==
                      todayKey,
                )
                .firstOrNull;
            final latest = records.isEmpty ? null : records.first;
            final weeklyKm = records.take(7).fold<double>(
                  0,
                  (sum, record) => sum + record.distanceKm,
                );
            final weeklySeconds = records.take(7).fold<int>(
                  0,
                  (sum, record) => sum + record.durationSeconds,
                );
            final averagePace =
                weeklyKm == 0 ? null : (weeklySeconds / weeklyKm).round();

            return RefreshIndicator(
              onRefresh: () async => setState(_refresh),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
                children: [
                  const _Header(),
                  const SizedBox(height: 26),
                  _TodayPanel(
                    todayRecord: todayRecord,
                    onStart: _openRecordForm,
                  ),
                  const SizedBox(height: 26),
                  const SectionHeader(
                    title: '이번 주',
                    subtitle: '최근 7개 기록 기준',
                  ),
                  Row(
                    children: [
                      StatTile(
                        label: '총 거리',
                        value: '${weeklyKm.toStringAsFixed(1)}km',
                        icon: Icons.route_outlined,
                      ),
                      const SizedBox(width: 12),
                      StatTile(
                        label: '평균 페이스',
                        value: averagePace == null
                            ? '--'
                            : '${formatPace(averagePace)}/km',
                        icon: Icons.speed_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: _SummaryRow(
                      label: '총 러닝 시간',
                      value: formatKoreanDuration(weeklySeconds),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const SectionHeader(title: '최근 러닝'),
                  if (latest == null)
                    const _EmptyRecentRun()
                  else
                    _RecentRunPanel(record: latest),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RunK',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '사람과 사람을 잇는 소셜 러닝',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayPanel extends StatelessWidget {
  const _TodayPanel({required this.todayRecord, required this.onStart});

  final RunningRecord? todayRecord;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final distance = todayRecord?.distanceKm.toStringAsFixed(1) ?? '0.0';
    final duration = todayRecord == null
        ? '0:00'
        : formatDuration(todayRecord!.durationSeconds);

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '오늘의 러닝',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '준비 완료',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeroMetric(value: distance, label: '거리 km'),
              const SizedBox(width: 24),
              _HeroMetric(value: duration, label: '시간'),
            ],
          ),
          const SizedBox(height: 18),
          const MapPreview(height: 112, label: '러닝 지도'),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('러닝 시작'),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.value, required this.label});

  final String value;
  final String label;

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
            style: TextStyle(
              color: AppColors.text,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _RecentRunPanel extends StatelessWidget {
  const _RecentRunPanel({required this.record});

  final RunningRecord record;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${record.runDate.month}월 ${record.runDate.day}일',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _CompactMetric(
                value: record.distanceKm.toStringAsFixed(1),
                label: '거리 km',
              ),
              _CompactMetric(
                value: formatDuration(record.durationSeconds),
                label: '시간',
              ),
              _CompactMetric(
                value: formatPace(record.paceSecondsPerKm),
                label: '페이스',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyRecentRun extends StatelessWidget {
  const _EmptyRecentRun();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Text(
        '아직 저장된 러닝 기록이 없습니다.',
        style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.value, required this.label});

  final String value;
  final String label;

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
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
