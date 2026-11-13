import 'package:flutter/material.dart';

/// Shows the entered email with a "Change" button, used on the OTP stage.
class ChangeEmailHeader extends StatelessWidget {
  final String email;
  final bool isLoading;
  final VoidCallback onChangeEmail;

  const ChangeEmailHeader({
    super.key,
    required this.email,
    required this.isLoading,
    required this.onChangeEmail,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            email,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : onChangeEmail,
          child: const Text('Change'),
        ),
      ],
    );
  }
}

/// Email input field with validation.
class EmailInputField extends StatelessWidget {
  final TextEditingController controller;

  const EmailInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'Email Address',
        hintText: 'you@example.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Email is required';
        final emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!emailRe.hasMatch(val.trim())) return 'Enter a valid email address';
        return null;
      },
    );
  }
}

/// 6-digit OTP entry field.
class OtpInputSection extends StatelessWidget {
  final TextEditingController controller;

  const OtpInputSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      style: textTheme.headlineLarge?.copyWith(letterSpacing: 8.0),
      decoration: const InputDecoration(
        labelText: '6-Digit Code',
        hintText: '------',
        counterText: '',
        prefixIcon: Icon(Icons.pin_outlined),
      ),
      validator: (val) {
        if (val == null || val.trim().length != 6) return 'Enter the 6-digit code';
        return null;
      },
    );
  }
}
