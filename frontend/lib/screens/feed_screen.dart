import 'package:flutter/material.dart';

import '../models/running_record.dart';
import '../services/api_client.dart';
import '../widgets/running_record_card.dart';
import 'profile_screen.dart';
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
    _feedFuture = widget.apiClient.fetchFeed();
  }

  void _refresh() {
    setState(() {
      _feedFuture = widget.apiClient.fetchFeed();
    });
  }

  Future<void> _openRecordForm() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecordFormScreen(apiClient: widget.apiClient),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('런크 피드'),
        actions: [
          IconButton(
            tooltip: '프로필',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProfileScreen(apiClient: widget.apiClient),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRecordForm,
        icon: const Icon(Icons.add),
        label: const Text('기록'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<RunningRecord>>(
          future: _feedFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('피드를 불러오지 못했습니다.\n${snapshot.error}'),
                  ),
                ],
              );
            }
            final records = snapshot.data ?? [];
            if (records.isEmpty) {
              return const Center(child: Text('아직 러닝 기록이 없습니다.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  RunningRecordCard(record: records[index]),
            );
          },
        ),
      ),
    );
  }
}
