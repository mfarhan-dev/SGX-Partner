import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, PostgrestException;

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/cnic_formatter.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../shared/constants/kpk_areas.dart';
import '../../../../shared/widgets/searchable_list_sheet.dart';

class WholesalerProfileFormResult {
  const WholesalerProfileFormResult({
    required this.ownerName,
    required this.area,
    required this.shopName,
    this.phone,
    this.cnic,
    this.address,
    this.photoFile,
  });

  final String ownerName;
  final String area;
  final String shopName;

  /// Only set when the form allows editing the phone (Edit Profile --
  /// there is no onboarding form for wholesalers, see the screen doc
  /// comment) -- the local 03XXXXXXXXX the user typed, which may or may
  /// not differ from what they started with. The caller decides what to
  /// do if it changed (trigger a phone-change OTP).
  final String? phone;

  final String? cnic;
  final String? address;

  /// Null means "no new photo picked" -- for editing, that means keep
  /// whatever photo already exists; the caller decides what null means.
  final File? photoFile;
}

/// Edit-only counterpart to MechanicProfileForm -- wholesalers are
/// always pre-created by staff (shop_name/owner_name/phone/area are all
/// NOT NULL on the wholesalers table, and claim_partner_profile() marks
/// a claimed wholesaler complete unconditionally), so there is no
/// "fill this in for the first time" onboarding case to share fields
/// with, only editing an already-complete profile. Also has no
/// location/GPS capture -- the wholesalers table has no
/// latitude/longitude columns, unlike mechanics.
class WholesalerProfileForm extends StatefulWidget {
  const WholesalerProfileForm({
    super.key,
    required this.phoneNumber,
    required this.submitLabel,
    required this.submitIcon,
    required this.onSubmit,
    this.allowPhoneEdit = false,
    this.initialOwnerName,
    this.initialCnic,
    this.initialShopName,
    this.initialArea,
    this.initialAddress,
    this.initialPhotoUrl,
  });

  final String? phoneNumber;
  final String submitLabel;
  final IconData submitIcon;
  final Future<void> Function(WholesalerProfileFormResult result) onSubmit;

  final bool allowPhoneEdit;

  final String? initialOwnerName;
  final String? initialCnic;
  final String? initialShopName;
  final String? initialArea;
  final String? initialAddress;

  /// Existing photo to preview (signed URL) until the user picks a new
  /// one.
  final String? initialPhotoUrl;

  @override
  State<WholesalerProfileForm> createState() => _WholesalerProfileFormState();
}

class _WholesalerProfileFormState extends State<WholesalerProfileForm> {
  late final _ownerNameController = TextEditingController(
    text: widget.initialOwnerName,
  );
  late final _phoneController = TextEditingController(text: widget.phoneNumber);
  late final _shopNameController = TextEditingController(
    text: widget.initialShopName,
  );
  late final _addressController = TextEditingController(
    text: widget.initialAddress,
  );
  late final _cnicController = TextEditingController(text: widget.initialCnic);
  late String? _area = widget.initialArea;
  File? _photoFile;
  bool _isSubmitting = false;

  // Field-specific errors, shown inline under the field they belong to
  // -- a single shared error message rendered in one fixed spot on the
  // page leaves the user guessing which field it was even about.
  String? _ownerNameError;
  String? _phoneError;
  String? _shopNameError;
  String? _areaError;
  String? _cnicError;
  String? _submitError;

  @override
  void dispose() {
    _ownerNameController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _addressController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: _buildPhotoPicker(context)),
        const SizedBox(height: AppSpacing.xl),
        if (widget.allowPhoneEdit) ...[
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            onChanged: (_) {
              if (_phoneError != null) {
                setState(() => _phoneError = null);
              }
            },
            decoration: InputDecoration(
              labelText: 'Mobile Number *',
              prefixIcon: const Icon(Icons.smartphone),
              counterText: '',
              errorText: _phoneError,
              helperText: 'Changing this sends a code to the new number.',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ] else ...[
          Card(
            color: AppColors.successContainer,
            child: ListTile(
              leading: const Icon(Icons.verified, color: AppColors.success),
              title: Text(
                'Verified phone',
                style: TextStyle(
                  color: AppColors.textOf(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                widget.phoneNumber ?? '—',
                style: TextStyle(color: AppColors.mutedTextOf(context)),
              ),
              trailing: Icon(
                Icons.lock_outline,
                color: AppColors.mutedTextOf(context),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        TextField(
          controller: _ownerNameController,
          onChanged: (_) {
            if (_ownerNameError != null) {
              setState(() => _ownerNameError = null);
            }
          },
          decoration: InputDecoration(
            labelText: 'Owner Name *',
            prefixIcon: const Icon(Icons.person_outline),
            errorText: _ownerNameError,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _shopNameController,
          onChanged: (_) {
            if (_shopNameError != null) {
              setState(() => _shopNameError = null);
            }
          },
          decoration: InputDecoration(
            labelText: 'Shop Name *',
            prefixIcon: const Icon(Icons.storefront_outlined),
            errorText: _shopNameError,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
                color: _area == null ? AppColors.mutedTextOf(context) : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _addressController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Street / Area detail (optional)',
            hintText: 'e.g. Main Bazar, near Chowk',
            prefixIcon: Icon(Icons.signpost_outlined),
          ),
        ),
        if (_submitError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(_submitError!, style: const TextStyle(color: AppColors.error)),
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
                : Icon(widget.submitIcon),
            label: Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPicker(BuildContext context) {
    ImageProvider? backgroundImage;
    if (_photoFile != null) {
      backgroundImage = FileImage(_photoFile!);
    } else if (widget.initialPhotoUrl != null) {
      backgroundImage = NetworkImage(widget.initialPhotoUrl!);
    }

    return GestureDetector(
      onTap: _isSubmitting ? null : _pickPhoto,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.surfaceContainerOf(context),
            backgroundImage: backgroundImage,
            child: backgroundImage == null
                ? Icon(
                    Icons.person_outline,
                    size: 40,
                    color: AppColors.mutedTextOf(context),
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

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final ownerName = _ownerNameController.text.trim();
    final phone = _phoneController.text.trim();
    final shopName = _shopNameController.text.trim();
    final cnic = _cnicController.text.trim();

    setState(() {
      _ownerNameError = ownerName.length < 2 ? 'Enter the owner name.' : null;
      _phoneError =
          widget.allowPhoneEdit && !PhoneFormatter.isValidPakistanMobile(phone)
          ? 'Enter a valid phone number.'
          : null;
      _shopNameError = shopName.length < 2 ? 'Enter the shop name.' : null;
      _areaError = _area == null ? 'Select the area / city.' : null;
      _cnicError = cnic.isNotEmpty && !CnicFormatter.isValid(cnic)
          ? 'Enter a complete 13-digit CNIC, or leave it blank.'
          : null;
    });

    if (_ownerNameError != null ||
        _phoneError != null ||
        _shopNameError != null ||
        _areaError != null ||
        _cnicError != null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await widget.onSubmit(
        WholesalerProfileFormResult(
          ownerName: ownerName,
          area: _area!,
          shopName: shopName,
          phone: widget.allowPhoneEdit ? phone : null,
          cnic: cnic.isEmpty ? null : cnic,
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          photoFile: _photoFile,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      // A deliberate cancel (e.g. backing out of a phone-change OTP
      // step) isn't a failure -- just re-enable the button, no scary
      // red text for something the user chose to do.
      if (error is WholesalerProfileFormCancelled) {
        setState(() => _isSubmitting = false);
        return;
      }
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
    // Supabase's own Auth error text (e.g. phone-change failures like
    // "already registered") is already written for end users -- surface
    // it directly instead of a generic message that would hide why a
    // phone-number change specifically failed.
    if (error is AuthException) {
      return error.message;
    }
    return 'Could not save your profile. Please try again.';
  }
}

/// Thrown by an onSubmit callback (e.g. Edit Profile, when the user
/// backs out of a phone-change OTP prompt) to signal "the user chose
/// not to continue" rather than a real failure.
class WholesalerProfileFormCancelled implements Exception {
  const WholesalerProfileFormCancelled();
}
