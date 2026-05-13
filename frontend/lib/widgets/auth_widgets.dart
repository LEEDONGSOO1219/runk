import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({this.large = false, super.key});

  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'RunK',
          textAlign: TextAlign.center,
          style: (large
                  ? Theme.of(context).textTheme.displaySmall
                  : Theme.of(context).textTheme.headlineLarge)
              ?.copyWith(
            color: AppColors.text,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'CONNECTING PEOPLE THROUGH RUNNING',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w900,
                letterSpacing: large ? 1.1 : 0.7,
              ),
        ),
      ],
    );
  }
}

class AuthLineField extends StatelessWidget {
  const AuthLineField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(
        color: AppColors.text,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

class AuthLinkButton extends StatelessWidget {
  const AuthLinkButton({
    required this.text,
    required this.onTap,
    super.key,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.text,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class AuthLinkDivider extends StatelessWidget {
  const AuthLinkDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 12, color: AppColors.line);
  }
}

class SecondaryAuthButton extends StatelessWidget {
  const SecondaryAuthButton({
    this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: AppColors.text),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
