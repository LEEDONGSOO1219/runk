import 'package:flutter/material.dart';

import '../models/running_record.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_cards.dart';
import '../widgets/running_record_card.dart';
import 'record_form_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openRecordForm,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(_refresh),
          child: FutureBuilder<List<RunningRecord>>(
            future: _recordsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(22, 34, 22, 96),
                  children: [
                    const _RecordsHeader(),
                    const SizedBox(height: 22),
                    AppCard(child: Text('기록을 불러오지 못했습니다.\n${snapshot.error}')),
                  ],
                );
              }
              final records = snapshot.data ?? [];
              final totalKm = records.fold<double>(
                0,
                (sum, item) => sum + item.distanceKm,
              );
              final totalSeconds = records.fold<int>(
                0,
                (sum, item) => sum + item.durationSeconds,
              );
              final avgPace =
                  totalKm == 0 ? 0 : (totalSeconds / totalKm).round();

              return ListView(
                padding: const EdgeInsets.fromLTRB(22, 34, 22, 100),
                children: [
                  const _RecordsHeader(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      StatTile(
                        label: '누적 거리',
                        value: '${totalKm.toStringAsFixed(1)}km',
                        icon: Icons.route_outlined,
                      ),
                      const SizedBox(width: 12),
                      StatTile(
                        label: '평균 페이스',
                        value:
                            avgPace == 0 ? '--' : '${formatPace(avgPace)}/km',
                        icon: Icons.speed_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      StatTile(
                        label: '러닝 시간',
                        value: formatLongDuration(totalSeconds),
                        icon: Icons.timer_outlined,
                      ),
                      const SizedBox(width: 12),
                      StatTile(
                        label: '총 기록',
                        value: '${records.length}개',
                        icon: Icons.auto_graph,
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _ChartPanel(),
                  const SizedBox(height: 28),
                  const SectionHeader(title: '러닝 히스토리'),
                  if (records.isEmpty)
                    AppCard(
                      child: Text(
                        '아직 저장된 러닝 기록이 없습니다.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  else
                    for (final record in records) ...[
                      RunningRecordCard(record: record, showMap: true),
                      const SizedBox(height: 14),
                    ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RecordsHeader extends StatelessWidget {
  const _RecordsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기록',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '달린 만큼 선명해지는 나의 리듬',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '주간 흐름', subtitle: '최근 러닝 감각'),
          const SizedBox(height: 8),
          SizedBox(
            height: 116,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _Bar(day: '월', height: 46),
                _Bar(day: '화', height: 70),
                _Bar(day: '수', height: 38),
                _Bar(day: '목', height: 86),
                _Bar(day: '금', height: 64),
                _Bar(day: '토', height: 100),
                _Bar(day: '일', height: 54),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.day, required this.height});

  final String day;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 18,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
