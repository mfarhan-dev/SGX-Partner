import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Small OTP prompt shown from Edit Profile when the mobile number
/// field was changed. Returns the 6-digit code the user entered, or
/// null if they backed out (dismissed the sheet without confirming).
///
/// This does not call Supabase itself — the caller (edit screen)
/// already triggered the phone-change OTP via
/// `auth.updateUser(phone: ...)` before showing this, and verifies the
/// returned code via `auth.verifyOTP(type: OtpType.phoneChange, ...)`
/// after. Keeping this sheet dumb (just text entry) keeps the actual
/// Supabase calls in one place instead of split across two files.
Future<String?> showPhoneChangeOtpSheet({
  required BuildContext context,
  required String newPhoneNumber,
  String? errorText,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _PhoneChangeOtpSheet(
      newPhoneNumber: newPhoneNumber,
      initialError: errorText,
    ),
  );
}

class _PhoneChangeOtpSheet extends StatefulWidget {
  const _PhoneChangeOtpSheet({required this.newPhoneNumber, this.initialError});

  final String newPhoneNumber;
  final String? initialError;

  @override
  State<_PhoneChangeOtpSheet> createState() => _PhoneChangeOtpSheetState();
}

class _PhoneChangeOtpSheetState extends State<_PhoneChangeOtpSheet> {
  final _controller = TextEditingController();
  late String? _errorText = widget.initialError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetColor = AppColors.surfaceOf(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.outlineOf(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Verify new number',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'We sent a 6-digit code to ${widget.newPhoneNumber}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedTextOf(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) {
                    if (_errorText != null) setState(() => _errorText = null);
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '000000',
                    errorText: _errorText,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      final code = _controller.text.trim();
                      if (code.length != 6) {
                        setState(() => _errorText = 'Enter the 6-digit code.');
                        return;
                      }
                      Navigator.pop(context, code);
                    },
                    child: const Text('Confirm'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
