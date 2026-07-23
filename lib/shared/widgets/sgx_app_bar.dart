import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'sgx_logo.dart';

class SgxAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SgxAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
    this.showBrand = false,
    this.showNotifications = false,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final bool showBrand;
  final bool showNotifications;

  @override
  Widget build(BuildContext context) {
    final effectiveActions = <Widget>[
      if (showNotifications)
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.push('/notifications'),
          icon: Badge(
            isLabelVisible: true,
            label: const Text('3'),
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
      ...?actions,
    ];

    return AppBar(
      leading: showBack
          ? BackButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/mechanic/home');
                }
              },
            )
          : null,
      automaticallyImplyLeading: showBack,
      titleSpacing: showBrand ? 0 : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBrand) ...[
            const SgxLogo(size: 32),
            const SizedBox(width: 10),
          ],
          Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
        ],
      ),
      actions: effectiveActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
