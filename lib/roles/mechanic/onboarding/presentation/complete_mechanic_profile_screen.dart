import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../core/utils/cnic_formatter.dart';
import '../../../../shared/constants/kpk_areas.dart';
import '../../../../shared/widgets/searchable_list_sheet.dart';
import '../data/supabase_mechanic_onboarding_repository.dart';
import '../domain/mechanic_onboarding_draft.dart';

/// Solid, theme-independent tint for the location action — deliberately
/// NOT an alpha blend over the scaffold background, which turned nearly
/// invisible on the dark theme (a transparent red over near-black is
/// still near-black). Always renders the same light pink regardless of
/// theme, same strategy as the fixed successContainer/surfaceContainer
/// cards elsewhere on this screen.
const _locationTint = Color(0xFFF6E2E2);

/// Which settings screen (if any) the current location error can be
/// resolved from. Android stops showing its own permission dialog after
/// two denials (LocationPermission.deniedForever) — at that point the
/// only way forward is the app's own settings page, not another
/// in-app request.
enum _LocationSettingsAction { none, locationServices, appSettings }

/// One-time setup shown right after OTP verification when
/// `claim_partner_profile()` found no pre-created wholesaler/mechanic
/// record for this phone (see `otp_verification_screen.dart` routing).
/// Submitting calls `complete_mechanic_onboarding()`, which creates the
/// real `mechanics` row under this session's own profile id.
class CompleteMechanicProfileScreen extends ConsumerStatefulWidget {
  const CompleteMechanicProfileScreen({super.key});

  @override
  ConsumerState<CompleteMechanicProfileScreen> createState() =>
      _CompleteMechanicProfileScreenState();
}

class _CompleteMechanicProfileScreenState
    extends ConsumerState<CompleteMechanicProfileScreen> {
  final _fullNameController = TextEditingController();
  final _workshopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cnicController = TextEditingController();
  String? _area;
  File? _photoFile;
  Position? _position;
  bool _isLocating = false;
  bool _isSubmitting = false;

  // Field-specific errors, shown inline under the field they belong to
  // — a single shared error message rendered in one fixed spot on the
  // page (the old behavior) left the user guessing which field it was
  // even about.
  String? _fullNameError;
  String? _workshopNameError;
  String? _areaError;
  String? _cnicError;
  String? _submitError;
  String? _locationErrorText;
  _LocationSettingsAction _locationSettingsAction =
      _LocationSettingsAction.none;

  @override
  void dispose() {
    _fullNameController.dispose();
    _workshopNameController.dispose();
    _addressController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = ref.watch(authControllerProvider).phoneNumber;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // This is the very first screen after OTP verification — there is
    // nothing meaningful to go "back" to (Change number lives on the
    // OTP screen already gone from the stack). No app bar, no back
    // button: the system back gesture just exits, like a landing screen.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              Text(
                'Complete your profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(child: _buildPhotoPicker(context)),
              const SizedBox(height: AppSpacing.xl),
              Card(
                color: AppColors.successContainer,
                child: ListTile(
                  leading: const Icon(Icons.verified, color: AppColors.success),
                  title: const Text(
                    'Verified phone',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    phoneNumber ?? '—',
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                  trailing: const Icon(
                    Icons.lock_outline,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _fullNameController,
                onChanged: (_) {
                  if (_fullNameError != null) {
                    setState(() => _fullNameError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: const Icon(Icons.person_outline),
                  errorText: _fullNameError,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _cnicController,
                keyboardType: TextInputType.number,
                inputFormatters: [CnicInputFormatter()],
                onChanged: (_) {
                  if (_cnicError != null) {
                    setState(() => _cnicError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'CNIC (optional)',
                  hintText: '00000-0000000-0',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  errorText: _cnicError,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _workshopNameController,
                onChanged: (_) {
                  if (_workshopNameError != null) {
                    setState(() => _workshopNameError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Workshop / Shop Name *',
                  prefixIcon: const Icon(Icons.storefront_outlined),
                  errorText: _workshopNameError,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickArea,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Area / City *',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: const Icon(Icons.expand_more),
                    errorText: _areaError,
                  ),
                  child: Text(
                    _area ?? 'Select area / city',
                    style: TextStyle(
                      color: _area == null ? AppColors.mutedText : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Street / Area detail (optional)',
                  hintText: 'e.g. Main Bazar, near Chowk',
                  prefixIcon: Icon(Icons.signpost_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildLocationCapture(context),
              if (_submitError != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _submitError!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker(BuildContext context) {
    return GestureDetector(
      onTap: _isSubmitting ? null : _pickPhoto,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.surfaceContainer,
            backgroundImage: _photoFile != null ? FileImage(_photoFile!) : null,
            child: _photoFile == null
                ? const Icon(
                    Icons.person_outline,
                    size: 40,
                    color: AppColors.mutedText,
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCapture(BuildContext context) {
    if (_position != null) {
      return Card(
        color: AppColors.successContainer,
        child: ListTile(
          leading: const Icon(Icons.my_location, color: AppColors.success),
          title: const Text(
            'Location captured',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${_position!.latitude.toStringAsFixed(5)}, '
            '${_position!.longitude.toStringAsFixed(5)}',
            style: const TextStyle(color: AppColors.mutedText),
          ),
          trailing: TextButton(
            onPressed: _isLocating ? null : _captureLocation,
            child: const Text('Retake'),
          ),
        ),
      );
    }

    // Only one thing on screen at a time, one obvious action each time
    // — no small caption text competing with a separate small link.
    // Matches how Swiggy/PayPal/Tinder handle this: a short line plus
    // one large button, never a silent redirect with no explanation.
    if (_locationSettingsAction != _LocationSettingsAction.none) {
      final isServicesOff =
          _locationSettingsAction == _LocationSettingsAction.locationServices;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: _locationTint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isServicesOff
                  ? 'Location is turned off on this phone.'
                  : 'Location is turned off for this app.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: _openLocationSettings,
                child: Text(isServicesOff ? 'Turn it on' : 'Fix in Settings'),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: _locationTint,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _isLocating ? null : _captureLocation,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              child: Row(
                children: [
                  _isLocating
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _isLocating
                        ? 'Getting location…'
                        : 'Use my current location',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Only the plain "denied, try again" / one-off failure cases
        // land here — GPS-off and permanently-denied are their own full
        // takeover state above, not a caption under this row.
        if (_locationErrorText != null) ...[
          const SizedBox(height: 4),
          Text(
            _locationErrorText!,
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Future<void> _pickArea() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final selected = await showSearchableListSheet(
      context: context,
      title: 'Area / City',
      items: kKpkAreas,
      selected: _area,
    );
    if (selected != null) {
      setState(() {
        _area = selected;
        _areaError = null;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _photoFile = File(picked.path));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitError = 'Could not access camera/gallery.');
    }
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isLocating = true;
      _locationErrorText = null;
      _locationSettingsAction = _LocationSettingsAction.none;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() {
          _locationErrorText =
              'Location services are turned off on this device.';
          _locationSettingsAction = _LocationSettingsAction.locationServices;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      // Only the FIRST denial gets another in-app prompt. Android (and
      // iOS) stop showing their own permission dialog after that —
      // requesting again here would silently no-op, so deniedForever
      // routes straight to app settings instead of looping forever.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationErrorText =
              'Location permission is turned off for this app. You can still continue without it.';
          _locationSettingsAction = _LocationSettingsAction.appSettings;
        });
        return;
      }
      if (permission == LocationPermission.denied) {
        setState(
          () => _locationErrorText =
              'Location permission was denied. You can still continue without it.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() => _position = position);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _locationErrorText = 'Could not get your location right now.',
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _openLocationSettings() async {
    switch (_locationSettingsAction) {
      case _LocationSettingsAction.locationServices:
        await Geolocator.openLocationSettings();
      case _LocationSettingsAction.appSettings:
        await Geolocator.openAppSettings();
      case _LocationSettingsAction.none:
        break;
    }
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final fullName = _fullNameController.text.trim();
    final workshopName = _workshopNameController.text.trim();
    final cnic = _cnicController.text.trim();

    setState(() {
      _fullNameError = fullName.length < 2 ? 'Enter your full name.' : null;
      _workshopNameError = workshopName.length < 2
          ? 'Enter your workshop / shop name.'
          : null;
      _areaError = _area == null ? 'Select your area / city.' : null;
      _cnicError = cnic.isNotEmpty && !CnicFormatter.isValid(cnic)
          ? 'Enter a complete 13-digit CNIC, or leave it blank.'
          : null;
    });

    if (_fullNameError != null ||
        _workshopNameError != null ||
        _areaError != null ||
        _cnicError != null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await ref
          .read(mechanicOnboardingRepositoryProvider)
          .completeProfile(
            MechanicOnboardingDraft(
              fullName: fullName,
              city: _area!,
              workshopName: workshopName,
              cnic: cnic.isEmpty ? null : cnic,
              address: _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
              latitude: _position?.latitude,
              longitude: _position?.longitude,
              photoFile: _photoFile,
            ),
          );
      if (!mounted) return;
      context.go('/mechanic/home');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = _messageFor(error);
      });
    }
  }

  String _messageFor(Object error) {
    if (error is PostgrestException &&
        error.code == '23505' &&
        (error.message.contains('cnic') ||
            error.details.toString().contains('cnic'))) {
      return 'This CNIC is already registered to another account.';
    }
    return 'Could not save your profile. Please try again.';
  }
}
