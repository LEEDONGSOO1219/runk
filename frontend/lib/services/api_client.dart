import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  static const _tokenKey = 'auth.accessToken';
  static const _userKey = 'auth.currentUser';

  bool get isLoggedIn => _token != null;

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (token == null || userJson == null) {
      return;
    }

    try {
      _token = token;
      currentUser = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      await fetchMyProfile();
    } catch (_) {
      await logout();
    }
  }

  Future<void> logout() async {
    _token = null;
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> signup({
    required String email,
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );
    _throwIfFailed(response);
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

  Future<bool> isEmailAvailable(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/check-email').replace(
        queryParameters: {'email': email},
      ),
      headers: _headers,
    );
    _throwIfFailed(response);
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return data['available'] == true;
  }

  Future<bool> isUsernameAvailable(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/check-username').replace(
        queryParameters: {'username': username},
      ),
      headers: _headers,
    );
    _throwIfFailed(response);
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return data['available'] == true;
  }

  Future<List<RunningRecord>> fetchFeed() async {
    final response = await http.get(Uri.parse('$baseUrl/feed?limit=50'));
    _throwIfFailed(response);
    final rows = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return rows
        .map((row) => RunningRecord.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<User> fetchMyProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
    );
    _throwIfFailed(response);
    currentUser = User.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
    await _persistSession();
    return currentUser!;
  }

  Future<List<RunningRecord>> fetchMyRecords() async {
    final response = await http.get(
      Uri.parse('$baseUrl/running-records/me'),
      headers: _headers,
    );
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
    await _persistSession();
  }

  Future<void> _persistSession() async {
    if (_token == null || currentUser == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token!);
    await prefs.setString(_userKey, jsonEncode(currentUser!.toJson()));
  }

  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final body = utf8.decode(response.bodyBytes);
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String) {
          throw ApiException(_localizeError(detail), response.statusCode);
        }
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map<String, dynamic> && first['msg'] is String) {
            throw ApiException(
              _localizeError(first['msg'] as String),
              response.statusCode,
            );
          }
        }
      }
    } on FormatException {
      // Fall through to the generic message below.
    }

    throw ApiException(
      '요청을 처리하지 못했습니다. 잠시 후 다시 시도해 주세요.',
      response.statusCode,
    );
  }

  String _localizeError(String message) {
    return switch (message) {
      'Invalid email or password' => '이메일 또는 비밀번호가 올바르지 않습니다.',
      'Email or username already exists' => '이미 사용 중인 이메일 또는 닉네임입니다.',
      'Email already exists' => '이미 사용 중인 이메일입니다.',
      'Username already exists' => '이미 사용 중인 닉네임입니다.',
      'Password must not contain spaces' => '비밀번호에는 공백을 사용할 수 없습니다.',
      'Password must include both letters and numbers' =>
        '비밀번호에는 영문과 숫자가 모두 필요합니다.',
      'Password must combine at least two of letters, numbers, and special characters' =>
        '비밀번호는 영문, 숫자, 특수문자 중 2가지 이상을 조합해야 합니다.',
      _ => message,
    };
  }
}

class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
