import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_state.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/widgets/sgx_app_bar.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _controller = TextEditingController(text: '123456');
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isLoading = auth.status == AuthStatus.checking;

    return Scaffold(
      appBar: const SgxAppBar(title: 'OTP Verification'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Enter the OTP sent to ${auth.phoneNumber ?? 'your phone'}.'),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'OTP',
                errorText: _errorText ?? auth.errorMessage,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final otp = _controller.text.trim();
    if (otp.isEmpty) {
      setState(() => _errorText = 'OTP is required.');
      return;
    }
    setState(() => _errorText = null);
    await ref.read(authControllerProvider.notifier).verifyOtp(otp);
    final auth = ref.read(authControllerProvider);
    if (!mounted) return;
    if (auth.status == AuthStatus.accountUnavailable) {
      context.go('/auth/account-unavailable');
    } else if (auth.profile?.role == AppRole.wholesaler) {
      context.go('/wholesaler/home');
    } else if (auth.profile?.isComplete == false || auth.profile == null) {
      context.go('/mechanic/onboarding');
    } else {
      context.go('/mechanic/home');
    }
  }
}
