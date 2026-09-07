import 'package:flutter/material.dart';

/// One labeled option for [showSingleChoiceDialog].
class SingleChoiceOption<T> {
  const SingleChoiceOption(this.value, this.label);

  final T value;
  final String label;
}

/// Compact single-choice picker for settings rows with just a couple of
/// options (Language, Theme) — a full bottom sheet is overkill for 2-3
/// items, so this uses a plain dialog with radio rows instead.
///
/// Returns the newly picked value, or null if the user dismissed the
/// dialog without choosing (tap outside, back button).
Future<T?> showSingleChoiceDialog<T>({
  required BuildContext context,
  required String title,
  required List<SingleChoiceOption<T>> options,
  required T selected,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => RadioGroup<T>(
      groupValue: selected,
      onChanged: (value) => Navigator.pop(context, value),
      child: SimpleDialog(
        title: Text(title),
        children: [
          for (final option in options)
            RadioListTile<T>(value: option.value, title: Text(option.label)),
        ],
      ),
    ),
  );
}
