import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/utils/phone_formatter.dart';
import '../../../shared/widgets/sgx_app_bar.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(authControllerProvider).status == AuthStatus.checking;

    return Scaffold(
      appBar: const SgxAppBar(title: 'Phone Login'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone number',
                hintText: '03XXXXXXXXX',
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final phone = _controller.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorText = 'Phone number is required.');
      return;
    }
    if (!PhoneFormatter.isValidPakistanMobile(phone)) {
      setState(() => _errorText = 'Enter a valid phone number.');
      return;
    }

    setState(() => _errorText = null);
    await ref.read(authControllerProvider.notifier).sendOtp(phone);
    if (mounted) context.go('/auth/otp');
  }
}
