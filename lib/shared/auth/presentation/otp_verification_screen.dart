import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_state.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/widgets/sgx_app_bar.dart';
import '../../../shared/widgets/sgx_logo.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _controller = TextEditingController(text: '123456');
  final _focusNode = FocusNode();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isLoading = auth.status == AuthStatus.checking;

    return Scaffold(
      appBar: const SgxAppBar(title: '', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Center(child: SgxLogo(size: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Verify your number',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text.rich(
              TextSpan(
                text: 'We sent a 6-digit code to\n',
                children: [
                  TextSpan(
                    text: _maskedPhone(auth.phoneNumber),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 36),
            GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final digits = _controller.text
                      .padRight(6)
                      .characters
                      .take(6)
                      .toList();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final value = digits[index].trim();
                      final active =
                          value.isNotEmpty || index == _controller.text.length;
                      return Container(
                        width: 46,
                        height: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: value.isNotEmpty
                              ? AppColors.primary.withValues(alpha: 0.06)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active
                                ? AppColors.primary
                                : AppColors.outline,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: value.isNotEmpty
                                ? AppColors.primary
                                : AppColors.text,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            Opacity(
              opacity: 0,
              child: SizedBox(
                height: 1,
                child: TextField(
                  focusNode: _focusNode,
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            if (_errorText != null || auth.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _errorText ?? auth.errorMessage ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Resend code in 00:24',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: const Text('Verify'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () => context.go('/auth/phone'),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Change number'),
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

  String _maskedPhone(String? phone) {
    if (phone == null || phone.length < 7) {
      return '0300-****567';
    }
    return '${phone.substring(0, 4)}-****${phone.substring(phone.length - 3)}';
  }
}
