import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/utils/phone_formatter.dart';
import '../../../shared/widgets/sgx_logo.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // No AppBar on this screen to auto-derive the status bar style, and
    // the splash screen before it forces light (white) icons for its red
    // background — without this, that white style leaks into this
    // screen. Must follow the actual theme brightness (not a hardcoded
    // .dark) since this screen's own background flips between light and
    // dark with the system theme.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - AppSpacing.lg * 2,
                  ),
                  child: IntrinsicHeight(
                    child: _buildContent(context, isLoading),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isLoading) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            onPressed: () {},
            icon: const Icon(Icons.language, size: 18),
            label: const Text('English'),
          ),
        ),
        const SizedBox(height: 40),
        const Center(child: SgxLogo(size: 72)),
        const SizedBox(height: AppSpacing.ml),
        Text(
          'Login to SGX Partners',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Enter your mobile number to continue.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.mutedTextOf(context),
          ),
        ),
        const SizedBox(height: 40),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            hintText: '03001234567',
            prefixIcon: const Icon(Icons.smartphone),
            counterText: '',
            errorText: _errorText,
          ),
        ),
        const SizedBox(height: AppSpacing.ml),
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
                : const Icon(Icons.sms_outlined),
            label: const Text('Send OTP'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'An SMS with a 6-digit code will be sent.\nStandard SMS charges may apply.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.mutedTextOf(context),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.badge_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wholesaler account required',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Wholesaler accounts are created by SGX staff. Unknown numbers continue to mechanic onboarding after OTP.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 16,
              color: AppColors.mutedTextOf(context),
            ),
            const SizedBox(width: 6),
            Text(
              'Secure login by SGX',
              style: TextStyle(
                color: AppColors.mutedTextOf(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final phone = _controller.text.replaceAll(RegExp(r'[\s-]'), '').trim();
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
    if (!mounted) return;

    final auth = ref.read(authControllerProvider);
    if (auth.status == AuthStatus.otpSent) {
      context.go('/auth/otp');
    } else {
      setState(
        () => _errorText = auth.errorMessage ?? 'Could not send the code.',
      );
    }
  }
}
