import 'package:flutter/material.dart';

import '../services/api_client.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.apiClient,
    required this.onAuthenticated,
    super.key,
  });

  final ApiClient apiClient;
  final VoidCallback onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignup = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (_isSignup) {
        await widget.apiClient.signup(
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await widget.apiClient.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      widget.onAuthenticated();
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('런크')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isSignup ? '러닝 시작하기' : '다시 달리기',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: '이메일'),
                    validator: (value) => value == null || !value.contains('@')
                        ? '이메일을 입력하세요.'
                        : null,
                  ),
                  if (_isSignup) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: '닉네임'),
                      validator: (value) => value == null || value.length < 2
                          ? '닉네임은 2자 이상입니다.'
                          : null,
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                    validator: (value) => value == null || value.length < 6
                        ? '비밀번호는 6자 이상입니다.'
                        : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: Text(
                        _isLoading ? '처리 중...' : (_isSignup ? '회원가입' : '로그인')),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _isSignup = !_isSignup),
                    child: Text(_isSignup ? '이미 계정이 있어요' : '새 계정 만들기'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
