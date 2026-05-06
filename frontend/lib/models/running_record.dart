class RunningRecord {
  const RunningRecord({
    required this.id,
    required this.username,
    required this.distanceKm,
    required this.durationSeconds,
    required this.paceSecondsPerKm,
    required this.runDate,
    this.memo,
  });

  final int id;
  final String username;
  final double distanceKm;
  final int durationSeconds;
  final int paceSecondsPerKm;
  final DateTime runDate;
  final String? memo;

  factory RunningRecord.fromJson(Map<String, dynamic> json) {
    return RunningRecord(
      id: json['id'] as int,
      username: json['username'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      durationSeconds: json['duration_seconds'] as int,
      paceSecondsPerKm: json['pace_seconds_per_km'] as int,
      runDate: DateTime.parse(json['run_date'] as String),
      memo: json['memo'] as String?,
    );
  }
}
