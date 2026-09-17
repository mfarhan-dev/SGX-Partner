import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_preferences.dart';

final themeModeProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);

const _themeModeKey = 'theme_mode';

/// Persisted per-device via [LocalPreferences] -- picking "Dark" in
/// Settings should still be dark after the OS kills and restarts the
/// app in the background. `ThemeMode.system` alone can't represent
/// that: it only ever reflects the phone's own setting, never a value
/// the partner picked in this app.
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = LocalPreferences.instance?.getString(_themeModeKey);
    return _fromStored(stored) ?? ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    // Fire-and-forget: Settings' own picker already reflects the new
    // mode via `state` the instant this returns, and a slow or failed
    // disk write shouldn't hold up that UI. Worst case -- the write
    // never lands -- just means the next cold start falls back to
    // `ThemeMode.system`, same as before this feature existed.
    unawaited(LocalPreferences.instance?.setString(_themeModeKey, mode.name));
  }

  static ThemeMode? _fromStored(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => null,
  };
}
