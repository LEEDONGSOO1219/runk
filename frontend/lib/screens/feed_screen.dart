import 'package:flutter/material.dart';

import '../models/running_record.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/app_cards.dart';
import '../widgets/running_record_card.dart';
import 'record_form_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<RunningRecord>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _feedFuture = widget.apiClient.fetchFeed();
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRecordForm,
        icon: const Icon(Icons.add),
        label: const Text('공유'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(_refresh),
          child: FutureBuilder<List<RunningRecord>>(
            future: _feedFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(22, 34, 22, 96),
                  children: [
                    const _FeedHeader(),
                    const SizedBox(height: 22),
                    AppCard(
                      child: Text('피드를 불러오지 못했습니다.\n${snapshot.error}'),
                    ),
                  ],
                );
              }
              final records = snapshot.data ?? [];
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 34, 22, 100),
                itemCount: records.isEmpty ? 3 : records.length + 2,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const _FeedHeader();
                  }
                  if (index == 1) {
                    return const SectionHeader(
                      title: '오늘의 피드',
                      subtitle: '친구들의 러닝 모먼트',
                    );
                  }
                  if (records.isEmpty) {
                    return AppCard(
                      child: Text(
                        '아직 공유된 러닝 기록이 없습니다.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    );
                  }
                  return RunningRecordCard(record: records[index - 2]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '피드',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '오늘의 기록을 조용히 나누는 공간',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
