import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the shell's own bottom nav bar (and FAB, on the mechanic
/// shell) should render at all right now. A full-bleed bottom sheet
/// like Withdraw Money sits in that exact same screen region, so it
/// flips this true right before opening and false again once it
/// closes -- the nav bar disappears instead of just floating on top
/// of (or dimmed behind) the sheet. Home's own content keeps the
/// normal Material scrim; only the nav chrome is removed.
class BottomChromeHidden extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool hidden) => state = hidden;
}

final bottomChromeHiddenProvider = NotifierProvider<BottomChromeHidden, bool>(
  BottomChromeHidden.new,
);
