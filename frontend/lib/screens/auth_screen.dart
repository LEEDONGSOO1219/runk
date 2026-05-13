import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

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
  final _passwordConfirmController = TextEditingController();

  bool _isSignup = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
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
        _clearInputs();
        setState(() => _isSignup = false);
        _showMessage('회원가입이 완료되었습니다. 로그인해 주세요.');
      } else {
        await widget.apiClient.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        widget.onAuthenticated();
      }
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearInputs() {
    _formKey.currentState?.reset();
    _emailController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _passwordConfirmController.clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return '이메일을 올바르게 입력해 주세요.';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (!_isSignup) {
      return null;
    }
    final username = value?.trim() ?? '';
    if (username.length < 2) {
      return '닉네임은 2자 이상이어야 합니다.';
    }
    if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(username)) {
      return '영문, 숫자, ., _, - 만 사용할 수 있습니다.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < 8 || password.length > 16) {
      return '비밀번호는 8~16자로 입력해 주세요.';
    }
    if (password.contains(RegExp(r'\s'))) {
      return '비밀번호에는 공백을 사용할 수 없습니다.';
    }
    final hasLetter = password.contains(RegExp('[a-zA-Z]'));
    final hasDigit = password.contains(RegExp('[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[^a-zA-Z0-9\s]'));
    final categoryCount =
        [hasLetter, hasDigit, hasSpecial].where((value) => value).length;
    if (categoryCount < 2) {
      return '영문, 숫자, 특수문자 중 2가지 이상을 조합해 주세요.';
    }
    return null;
  }

  String? _validatePasswordConfirm(String? value) {
    if (!_isSignup) {
      return null;
    }
    if ((value ?? '').isEmpty) {
      return '비밀번호를 한 번 더 입력해 주세요.';
    }
    if (value != _passwordController.text) {
      return '비밀번호가 일치하지 않습니다.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const AuthBrandMark(),
                    const SizedBox(height: 40),
                    Text(
                      _isSignup ? '회원가입' : '로그인',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignup
                          ? '러닝 기록을 공유할 계정을 만들어 주세요.'
                          : '오늘의 러닝을 기록하고 친구와 이어가세요.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 28),
                    AuthLineField(
                      controller: _emailController,
                      label: '이메일 주소',
                      hint: 'runk@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    if (_isSignup) ...[
                      const SizedBox(height: 16),
                      AuthLineField(
                        controller: _usernameController,
                        label: '닉네임',
                        hint: '영문, 숫자, ., _, - 사용 가능',
                        validator: _validateUsername,
                      ),
                    ],
                    const SizedBox(height: 16),
                    AuthLineField(
                      controller: _passwordController,
                      label: '비밀번호',
                      hint: _isSignup
                          ? '8~16자, 영문/숫자/특수문자 중 2가지 이상'
                          : '비밀번호를 입력해 주세요.',
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    if (_isSignup) ...[
                      const SizedBox(height: 16),
                      AuthLineField(
                        controller: _passwordConfirmController,
                        label: '비밀번호 확인',
                        hint: '비밀번호를 한 번 더 입력해 주세요.',
                        obscureText: true,
                        validator: _validatePasswordConfirm,
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: Text(
                        _isLoading ? '처리 중...' : (_isSignup ? '회원가입' : '로그인'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AuthLinkButton(
                          text: _isSignup ? '로그인' : '회원가입',
                          onTap: () {
                            setState(() {
                              _isSignup = !_isSignup;
                              _error = null;
                            });
                          },
                        ),
                        const AuthLinkDivider(),
                        AuthLinkButton(
                          text: '이메일 찾기',
                          onTap: () => _showMessage('이메일 찾기는 MVP 이후 확장 예정입니다.'),
                        ),
                        const AuthLinkDivider(),
                        AuthLinkButton(
                          text: '비밀번호 찾기',
                          onTap: () =>
                              _showMessage('비밀번호 찾기는 MVP 이후 확장 예정입니다.'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '간편 로그인',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SecondaryAuthButton(
                      icon: Icons.chat_bubble,
                      label: '카카오로 계속하기',
                      onTap: () => _showMessage('소셜 로그인은 MVP 이후 확장 예정입니다.'),
                    ),
                    const SizedBox(height: 10),
                    SecondaryAuthButton(
                      icon: Icons.apple,
                      label: 'Apple로 계속하기',
                      onTap: () => _showMessage('소셜 로그인은 MVP 이후 확장 예정입니다.'),
                    ),
                    const SizedBox(height: 10),
                    SecondaryAuthButton(
                      label: 'N   네이버로 계속하기',
                      onTap: () => _showMessage('소셜 로그인은 MVP 이후 확장 예정입니다.'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
