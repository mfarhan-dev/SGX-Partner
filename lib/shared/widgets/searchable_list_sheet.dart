import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Opens a rounded, near-full-height bottom sheet with a search field
/// and a scrollable list — the standard Material pattern for picking
/// one value out of a longer list (area/city, category, etc.), instead
/// of a cramped native dropdown menu.
///
/// Returns the selected item, or null if dismissed without a choice.
Future<String?> showSearchableListSheet({
  required BuildContext context,
  required String title,
  required List<String> items,
  String? selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _SearchableListSheet(title: title, items: items, selected: selected),
  );
}

class _SearchableListSheet extends StatefulWidget {
  const _SearchableListSheet({
    required this.title,
    required this.items,
    required this.selected,
  });

  final String title;
  final List<String> items;
  final String? selected;

  @override
  State<_SearchableListSheet> createState() => _SearchableListSheetState();
}

class _SearchableListSheetState extends State<_SearchableListSheet> {
  final _searchController = TextEditingController();
  late List<String> _filtered = widget.items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final normalized = query.trim().toLowerCase();
    setState(() {
      _filtered = normalized.isEmpty
          ? widget.items
          : widget.items
                .where((item) => item.toLowerCase().contains(normalized))
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sheetColor = AppColors.surfaceOf(context);

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search…',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No matches',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.mutedTextOf(context)),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: _filtered.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          final isSelected = item == widget.selected;
                          return ListTile(
                            title: Text(item),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () => Navigator.pop(context, item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
