import 'package:flutter/material.dart';

import '../services/api_client.dart';

class RecordFormScreen extends StatefulWidget {
  const RecordFormScreen({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<RecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  final _memoController = TextEditingController();
  DateTime _runDate = DateTime.now();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _distanceController.dispose();
    _durationController.dispose();
    _memoController.dispose();
    super.dispose();
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
        distanceKm: double.parse(_distanceController.text),
        durationSeconds: int.parse(_durationController.text) * 60,
        runDate: _runDate,
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('러닝 기록')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _distanceController,
                decoration: const InputDecoration(labelText: '거리(km)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  return parsed == null || parsed <= 0
                      ? '0보다 큰 거리를 입력하세요.'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: '시간(분)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  return parsed == null || parsed <= 0
                      ? '0보다 큰 시간을 입력하세요.'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(labelText: '메모'),
                maxLength: 255,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _runDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _runDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_runDate.toIso8601String().substring(0, 10)),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? '저장 중...' : '저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
