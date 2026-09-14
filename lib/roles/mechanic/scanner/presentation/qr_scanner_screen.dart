import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../profile/data/mechanic_profile_providers.dart';
import '../../wallet/data/mechanic_wallet_providers.dart';
import '../data/mechanic_scan_providers.dart';
import '../domain/scan_result.dart';
import 'widgets/scan_result_surface.dart';
import 'widgets/scanner_permission_view.dart';

/// The real scan-to-earn camera, replacing the old static gradient +
/// "Mock successful scan" button. "Ghost Link" of the demoed
/// directions: no bottom card at all -- a single quiet underlined link
/// floats directly on the camera feed below the frame, same weight and
/// placement as "Enter code manually" / "Enter ID instead" on Trust
/// Wallet, Uber, and Amazon Alexa's own scanners. Manual entry is
/// still a first-class, always-visible path (not just an error
/// fallback, since a QR sticker in a mechanic's workshop can be
/// smudged, torn, or badly lit) -- it's just no longer the loudest
/// thing on screen.
///
/// Tapping the link opens [_showManualEntrySheet] as a real
/// `showModalBottomSheet` -- the scan screen stays visible and dimmed
/// behind it, never a separate page. Both the camera decode and the
/// manual-entry path end at the exact same
/// [MechanicScanRepository.submitScan], which calls the real
/// scan_qr_code(p_qr_id) RPC -- already verified end-to-end in an
/// earlier session, just never connected to any UI until now.
///
/// Pushed on the root navigator, outside MechanicShell entirely (see
/// this route's own comment in app_routes.dart) -- so the shell's
/// bottom nav bar and centered FAB are never even in the tree while
/// this screen or its bottom sheet is open, with no "hide chrome"
/// flag to keep in sync.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  // True from the moment a code is captured (camera or manual) until
  // its result is dismissed -- guards against the camera firing
  // onDetect again for the same code while a scan is still in flight,
  // and against a double-tap on the manual-entry submit button.
  bool _processing = false;
  ScanResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleCode(String code) async {
    if (_processing) return;
    // Confirms a code was actually read the instant it happens -- on a
    // slow connection the server round-trip below can take several
    // seconds, and a light buzz right here is the only feedback a
    // mechanic gets that anything happened at all before the
    // "Verifying..." overlay itself has even had a frame to appear.
    unawaited(HapticFeedback.lightImpact());
    setState(() => _processing = true);
    await _controller.stop();

    final result = await ref
        .read(mechanicScanRepositoryProvider)
        .submitScan(code);

    if (!mounted) return;
    setState(() => _result = result);

    if (result.isSuccess) {
      unawaited(HapticFeedback.mediumImpact());
      // The reward was just credited server-side -- refetch everything
      // that shows a balance or the activity feed so they're correct
      // the instant the mechanic backs out of this screen, same
      // pattern as after a withdrawal request.
      ref.invalidate(mechanicProfileDataProvider);
      ref.invalidate(mechanicWalletActivityProvider);
    }
  }

  Future<void> _scanAnother() async {
    setState(() {
      _result = null;
      _processing = false;
    });
    await _controller.start();
  }

  Future<void> _showManualEntrySheet() async {
    final controller = TextEditingController();
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom:
                MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter code manually',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Type the code printed under the QR sticker.',
                style: Theme.of(sheetContext).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'e.g. QR-0031-02-014',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) => Navigator.pop(sheetContext, value),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext, controller.text),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (code != null && code.trim().isNotEmpty) {
      await _handleCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Leaving mid-scan shouldn't leave the camera running in the
      // background.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _controller.stop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C0C0E),
        body: Stack(
          children: [
            Positioned.fill(
              child: MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isEmpty) return;
                  final value = barcodes.first.rawValue;
                  if (value != null) _handleCode(value);
                },
                errorBuilder: (context, error) {
                  return ScannerPermissionView(
                    onRetry: () => _controller.start(),
                  );
                },
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _topBar(context),
                  Expanded(
                    child: Center(
                      child: SizedBox.square(
                        dimension: MediaQuery.sizeOf(context).width * 0.58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.55),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _footCaption(context),
                ],
              ),
            ),
            // A code was captured but the server hasn't answered yet --
            // real on a 3G/2G connection, where scan_qr_code()'s
            // round-trip can run several seconds. A looped spinner
            // plus a plain "what's happening" label is the right
            // pattern for an operation with no known duration (per
            // Smashing Magazine's progress-indicator guidance:
            // https://www.smashingmagazine.com/2016/12/best-practices-for-animated-progress-indicators/)
            // -- there's nothing to show a percentage of, so an
            // indeterminate indicator with real status text beats a
            // silent frozen camera image every time.
            if (_processing && _result == null)
              const Positioned.fill(child: _VerifyingOverlay()),
            if (_result != null)
              Positioned.fill(
                child: ScanResultSurface(
                  result: _result!,
                  onScanAnother: _scanAnother,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Row(
        children: [
          _RoundButton(
            // A pushed route now (see the route's own comment in
            // app_routes.dart) -- pop back to wherever the FAB was
            // tapped from, same convention as every other pushed
            // screen's close/back control in this app.
            icon: Icons.close,
            onTap: () => context.pop(),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Scan SGX QR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, child) {
              final on = state.torchState == TorchState.on;
              return _RoundButton(
                icon: on ? Icons.flash_on : Icons.flash_off,
                onTap: () => _controller.toggleTorch(),
              );
            },
          ),
        ],
      ),
    );
  }

  /// No card, no fill -- just the instruction and a quiet underlined
  /// link, both sitting directly on the dark camera feed. Explicit
  /// `Colors.white`/`white70` throughout (not a themed helper): this
  /// whole screen is a fixed-dark camera viewfinder regardless of the
  /// device's light/dark setting, same as every other scanner UI.
  Widget _footCaption(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Align the code in the frame',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Detection is automatic — no tap needed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 11.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: _showManualEntrySheet,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            icon: const Icon(Icons.keyboard_outlined, size: 16),
            label: const Text(
              'Enter code manually',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifyingOverlay extends StatelessWidget {
  const _VerifyingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      // Solid, same as ScanResultSurface -- not translucent, for the
      // same reason: a lower-alpha scrim here would let the idle
      // screen's aiming-frame decoration show through underneath it.
      color: const Color(0xFF0B0B0D),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3.5,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Verifying with SGX…',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'This can take a moment on a slow connection.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        foregroundColor: Colors.white,
      ),
      onPressed: onTap,
      icon: Icon(icon),
    );
  }
}
