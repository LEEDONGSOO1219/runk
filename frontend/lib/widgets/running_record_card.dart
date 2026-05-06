import 'package:flutter/material.dart';

import '../models/running_record.dart';

class RunningRecordCard extends StatelessWidget {
  const RunningRecordCard({required this.record, super.key});

  final RunningRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.username,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(record.runDate.toIso8601String().substring(0, 10)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${record.distanceKm.toStringAsFixed(2)} km',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '시간 ${_formatDuration(record.durationSeconds)} · 페이스 ${_formatPace(record.paceSecondsPerKm)} /km',
            ),
            if (record.memo != null && record.memo!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(record.memo!),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatPace(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
