import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_screen.dart';
import '../data/mechanic_profile_providers.dart';
import '../domain/mechanic_profile_data.dart';

class MechanicProfileScreen extends ConsumerWidget {
  const MechanicProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(mechanicProfileDataProvider);

    return SgxScreen(
      title: 'Settings',
      showNotifications: false,
      children: [
        profileAsync.when(
          data: (profile) => _ProfileHeader(profile: profile),
          loading: () => const _ProfileHeaderSkeleton(),
          error: (error, stackTrace) => Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Could not load your profile. Pull to refresh or try again later.',
                    style: TextStyle(color: AppColors.text),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SectionLabel('Account'),
        const SizedBox(height: AppSpacing.sm),
        _SettingsCard(
          children: [
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text('Verified Phone'),
              subtitle: Text(profileAsync.value?.phone ?? '—'),
              trailing: const Icon(Icons.lock_outline),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.storefront),
              title: const Text('Workshop'),
              subtitle: Text(profileAsync.value?.workshopName ?? '—'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Area / City'),
              subtitle: Text(profileAsync.value?.area ?? '—'),
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
              title: const Text('Language & Theme'),
              subtitle: const Text('English · Light'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/profile/preferences'),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Contact SGX'),
              subtitle: Text(
                profileAsync.value?.adminWhatsappNumber != null
                    ? 'WhatsApp: ${profileAsync.value!.adminWhatsappNumber}'
                    : '—',
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          onPressed: () => context.go('/auth/phone'),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
        const SizedBox(height: AppSpacing.md),
        const Center(child: Text('SGX Partners · v1.0.0')),
      ],
    );
  }
}

/// Small bold label above a settings group ("Account", "General") —
/// the grouped cards previously had no title at all, so the two
/// unlabeled cards back-to-back gave no hint what each one was for.
/// Sentence case, not ALL CAPS: a tracked-out caps eyebrow is a
/// generic "AI template" tell, not a deliberate choice for this app.
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

/// Explicit surface color + generous radius: the default Card color is
/// close enough to the cream scaffold background that the rounded
/// corners barely read against it — this makes the card unmistakably
/// a distinct, rounded surface.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final MechanicProfileData profile;

  @override
  Widget build(BuildContext context) {
    final initials = profile.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

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
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            backgroundImage: profile.photoUrl != null
                ? NetworkImage(profile.photoUrl!)
                : null,
            child: profile.photoUrl == null
                ? Text(
                    initials.isEmpty ? '?' : initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  [profile.workshopName, profile.area]
                      .where((part) => part != null && part.isNotEmpty)
                      .join(' · '),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          // Replaces the old "Edit Profile" row further down the
          // page — the edit action now lives right on the identity
          // it edits, not buried in a settings list.
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () => context.go('/mechanic/profile/edit'),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surfaceContainer,
      ),
      child: const Row(
        children: [
          CircleAvatar(radius: 32, backgroundColor: AppColors.outline),
          SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}
