import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_guards.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_state.dart';
import '../../../shared/widgets/sgx_app_bar.dart';
import '../../../shared/widgets/sgx_logo.dart';

/// Resend cooldown, in seconds, before the user can request a new code.
const _resendCooldownSeconds = 30;

/// No longer auto-fills the code for testing -- it used to call
/// `dev_get_latest_otp(p_phone)` right after `initState`, but that RPC
/// was `SECURITY DEFINER` and grantable to `anon`, meaning anyone
/// holding this project's public anon key (shipped inside the APK by
/// design) could read ANY partner's current login OTP with no session
/// of their own -- a full account-takeover path on an app that moves
/// real money. `anon`/`authenticated` EXECUTE has been revoked on that
/// function; it's callable only from the SQL editor now
/// (`select dev_get_latest_otp('03XXXXXXXXX')`), which is how the code
/// should be looked up for testing until a real SMS provider is
/// connected and `dev_otp_log` is retired entirely.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _errorText;
  Timer? _resendTimer;
  int _secondsRemaining = _resendCooldownSeconds;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _secondsRemaining = _resendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  Future<void> _resend() async {
    if (_secondsRemaining > 0) return;
    final phone = ref.read(authControllerProvider).phoneNumber;
    if (phone == null) return;
    setState(() {
      _errorText = null;
      _controller.clear();
    });
    await ref.read(authControllerProvider.notifier).sendOtp(phone);
    _startResendCountdown();
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
                    style: TextStyle(
                      color: AppColors.textOf(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedTextOf(context),
              ),
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
                                : AppColors.outlineOf(context),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: value.isNotEmpty
                                ? AppColors.primary
                                : AppColors.textOf(context),
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
            if (_secondsRemaining > 0)
              Text(
                'Resend code in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedTextOf(context),
                ),
              )
            else
              Center(
                child: TextButton(
                  onPressed: isLoading ? null : _resend,
                  child: const Text('Resend code'),
                ),
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
    FocusManager.instance.primaryFocus?.unfocus();

    final otp = _controller.text.trim();
    if (otp.isEmpty) {
      setState(() => _errorText = 'OTP is required.');
      return;
    }
    setState(() => _errorText = null);
    await ref.read(authControllerProvider.notifier).verifyOtp(otp);
    final auth = ref.read(authControllerProvider);
    if (!mounted) return;

    // Verification failed (wrong/expired code, network error, etc.) —
    // status stays otpSent and auth.errorMessage is already shown above.
    // Only a successful signedIn/accountUnavailable state carries a
    // real routing decision; RouteGuards is the single source of truth
    // for that decision, shared with the splash screen's session
    // restore so the two never drift out of sync.
    if (auth.status != AuthStatus.signedIn &&
        auth.status != AuthStatus.accountUnavailable) {
      return;
    }

    context.go(RouteGuards.protectedLanding(auth));
  }

  String _maskedPhone(String? phone) {
    if (phone == null || phone.length < 7) {
      return '0300-****567';
    }
    return '${phone.substring(0, 4)}-****${phone.substring(phone.length - 3)}';
  }
}
