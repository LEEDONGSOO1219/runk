import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/running_record.dart';
import '../models/user.dart';

class ApiClient {
  ApiClient({
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8000',
    ),
  });

  final String baseUrl;
  String? _token;
  User? currentUser;

  bool get isLoggedIn => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> signup({
    required String email,
    required String username,
    required String password,
  }) async {
    await _authenticate('/auth/signup', {
      'email': email,
      'username': username,
      'password': password,
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _authenticate('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<List<RunningRecord>> fetchFeed() async {
    final response = await http.get(Uri.parse('$baseUrl/feed'));
    _throwIfFailed(response);
    final rows = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return rows
        .map((row) => RunningRecord.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> createRunningRecord({
    required double distanceKm,
    required int durationSeconds,
    required DateTime runDate,
    String? memo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/running-records'),
      headers: _headers,
      body: jsonEncode({
        'distance_km': distanceKm,
        'duration_seconds': durationSeconds,
        'run_date': runDate.toIso8601String().substring(0, 10),
        'memo': memo,
      }),
    );
    _throwIfFailed(response);
  }

  Future<void> _authenticate(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _throwIfFailed(response);
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    _token = data['access_token'] as String;
    currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
  }

  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw Exception(utf8.decode(response.bodyBytes));
  }
}
