import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/partner_avatar.dart';
import '../../../../shared/widgets/settings_screen_skeleton.dart';
import '../../../../shared/widgets/sgx_screen.dart';
import '../../../../shared/widgets/single_choice_dialog.dart';
import '../data/wholesaler_profile_providers.dart';
import '../domain/wholesaler_profile_data.dart';

/// Mirrors mechanic_profile_screen.dart: real Supabase-backed profile
/// (fetched once per session, see wholesalerProfileDataProvider),
/// pencil-icon edit on the header, Language/Theme picker dialogs
/// (display-only for now), a WhatsApp deep link for Contact SGX, and a
/// confirm-before-logout flow that actually signs out of Supabase.
class WholesalerProfileScreen extends ConsumerStatefulWidget {
  const WholesalerProfileScreen({super.key});

  @override
  ConsumerState<WholesalerProfileScreen> createState() =>
      _WholesalerProfileScreenState();
}

class _WholesalerProfileScreenState
    extends ConsumerState<WholesalerProfileScreen> {
  // Display-only for now -- picking a value here doesn't change the
  // app's actual locale or theme yet. Defaults match what the app
  // already ships with: English, Light.
  String _language = 'English';
  String _themeLabel = 'Light';

  Future<void> _pickLanguage() async {
    final picked = await showSingleChoiceDialog<String>(
      context: context,
      title: 'Language',
      selected: _language,
      options: const [
        SingleChoiceOption('English', 'English'),
        SingleChoiceOption('Urdu', 'اردو (Urdu)'),
      ],
    );
    if (picked != null) setState(() => _language = picked);
  }

  Future<void> _pickTheme() async {
    final picked = await showSingleChoiceDialog<String>(
      context: context,
      title: 'Theme',
      selected: _themeLabel,
      options: const [
        SingleChoiceOption('Light', 'Light'),
        SingleChoiceOption('Dark', 'Dark'),
        SingleChoiceOption('System default', 'System default'),
      ],
    );
    if (picked != null) setState(() => _themeLabel = picked);
  }

  Future<void> _contactSgx(String? whatsappNumber) async {
    if (whatsappNumber == null || whatsappNumber.isEmpty) return;

    final digits = whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final international = digits.startsWith('0')
        ? '92${digits.substring(1)}'
        : digits;

    final uri = Uri.parse('https://wa.me/$international');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }

  Future<void> _logout() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Log out?',
      message:
          'You will need to verify your phone number again to sign '
          'back in.',
      confirmLabel: 'Log out',
      isDestructive: true,
    );
    if (!confirmed) return;

    await ref.read(authControllerProvider.notifier).signOut();
    if (mounted) context.go('/auth/phone');
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(wholesalerProfileDataProvider);

    return SgxScreen(
      title: 'Settings',
      showNotifications: false,
      // Riverpod's own AsyncValue.when() only takes the loading branch
      // for a genuine first fetch with nothing to show yet -- a
      // refetch after an edit (which still has the previous value)
      // keeps rendering `data` with the old value instead of flashing
      // the skeleton over already-good content.
      children: profileAsync.when(
        data: (profile) => _content(profile),
        loading: () => const [SettingsScreenSkeleton()],
        error: (error, stackTrace) => _content(null),
      ),
    );
  }

  List<Widget> _content(WholesalerProfileData? profile) {
    return [
      if (profile != null)
        _ProfileHeader(profile: profile)
      else
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.errorContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Could not load your profile. Pull to refresh or try again later.',
                  style: TextStyle(color: AppColors.textOf(context)),
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: AppSpacing.lg),
      const _SectionLabel('Account'),
      const SizedBox(height: AppSpacing.sm),
      _SettingsCard(
        children: [
          ListTile(
            leading: const Icon(Icons.smartphone),
            title: const Text('Registered Phone'),
            subtitle: Text(profile?.phone ?? '—'),
            trailing: const Icon(Icons.lock_outline),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.storefront),
            title: const Text('Shop Name'),
            subtitle: Text(profile?.shopName ?? '—'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Area / City'),
            subtitle: Text(profile?.area ?? '—'),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      const _SectionLabel('Payments'),
      const SizedBox(height: AppSpacing.sm),
      _SettingsCard(
        children: [
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: const Text('Payout Method'),
            subtitle: Text(profile?.payoutMethod?.label ?? 'Not set up'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/wholesaler/payout-method'),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      const _SectionLabel('General'),
      const SizedBox(height: AppSpacing.sm),
      _SettingsCard(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickLanguage,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Theme'),
            subtitle: Text(_themeLabel),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickTheme,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Contact SGX'),
            subtitle: Text(
              profile?.adminWhatsappNumber != null
                  ? 'WhatsApp: ${profile!.adminWhatsappNumber}'
                  : '—',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _contactSgx(profile?.adminWhatsappNumber),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
      ),
      const SizedBox(height: AppSpacing.md),
      const Center(child: Text('SGX Partners · v1.0.0')),
    ];
  }
}

/// Small bold label above a settings group ("Account", "General") --
/// mirrors mechanic_profile_screen.dart's _SectionLabel.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Explicit surface color + generous radius -- mirrors
/// mechanic_profile_screen.dart's _SettingsCard.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceOf(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.outlineOf(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final WholesalerProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Row(
        children: [
          PartnerAvatar(
            name: profile.ownerName,
            photoUrl: profile.photoUrl,
            radius: 32,
            backgroundColor: Colors.white24,
            foregroundColor: Colors.white,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.ownerName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  [profile.shopName, profile.area]
                      .where((part) => part != null && part.isNotEmpty)
                      .join(' · '),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () => context.go('/wholesaler/profile/edit'),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
          ),
        ],
      ),
    );
  }
}
