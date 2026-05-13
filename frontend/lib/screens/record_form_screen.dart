import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_cards.dart';

class RecordFormScreen extends StatefulWidget {
  const RecordFormScreen({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<RecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController();
  final _memoController = TextEditingController();
  DateTime _runDate = DateTime.now();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _distanceController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  double? get _distanceKm => double.tryParse(_distanceController.text.trim());

  int get _durationSeconds {
    final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    return (hours * 3600) + (minutes * 60);
  }

  int? get _paceSecondsPerKm {
    final distance = _distanceKm;
    final duration = _durationSeconds;
    if (distance == null || distance <= 0 || duration <= 0) {
      return null;
    }
    return (duration / distance).round();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await widget.apiClient.createRunningRecord(
        distanceKm: _distanceKm!,
        durationSeconds: _durationSeconds,
        runDate: _runDate,
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _runDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _runDate = picked);
    }
  }

  String? _validateDistance(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) {
      return '0보다 큰 거리를 입력해 주세요.';
    }
    return null;
  }

  String? _validateDurationPart(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) {
      return '0 이상의 숫자를 입력해 주세요.';
    }
    return null;
  }

  String? _validateMinutes(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0 || parsed > 59) {
      return '분은 0~59 사이로 입력해 주세요.';
    }
    if (_durationSeconds <= 0) {
      return '러닝 시간을 입력해 주세요.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        '${_runDate.year}.${_runDate.month.toString().padLeft(2, '0')}.${_runDate.day.toString().padLeft(2, '0')}';
    final pace = _paceSecondsPerKm;

    return Scaffold(
      appBar: AppBar(title: const Text('러닝 기록')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          children: [
            const MapPreview(height: 176, label: '러닝 위치 미리보기'),
            const SizedBox(height: 18),
            Row(
              children: [
                StatTile(
                  label: '거리',
                  value: _distanceKm == null
                      ? '--'
                      : '${_distanceKm!.toStringAsFixed(2)}km',
                  icon: Icons.route_outlined,
                ),
                const SizedBox(width: 12),
                StatTile(
                  label: '예상 페이스',
                  value: pace == null ? '--' : '${formatPace(pace)}/km',
                  icon: Icons.speed_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '오늘의 러닝',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _distanceController,
                    decoration: const InputDecoration(
                      labelText: '거리',
                      hintText: '예: 5.20',
                      suffixText: 'km',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: _validateDistance,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hoursController,
                          decoration: const InputDecoration(
                            labelText: '시간',
                            suffixText: '시간',
                          ),
                          keyboardType: TextInputType.number,
                          validator: _validateDurationPart,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _minutesController,
                          decoration: const InputDecoration(
                            labelText: '분',
                            suffixText: '분',
                          ),
                          keyboardType: TextInputType.number,
                          validator: _validateMinutes,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(dateText),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _memoController,
                    decoration: const InputDecoration(
                      labelText: '메모',
                      hintText: '오늘 러닝은 어땠나요?',
                    ),
                    maxLength: 255,
                    maxLines: 3,
                  ),
                  if (_durationSeconds > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '총 시간 ${formatLongDuration(_durationSeconds)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isSaving ? '저장 중...' : '기록 저장'),
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
