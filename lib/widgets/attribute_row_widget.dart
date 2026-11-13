import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'new_badge.dart';

/// An attribute key/value row with autocomplete fields and "new" badges.
///
/// [keyController] / [valueController] are the text controllers for each field.
/// [isPredefined] makes the key field read-only (for category-defined keys).
/// [knownKeyNames] is the set of existing key names (lowercased) for badge logic.
/// [valueSuggestions] are autocomplete options for the value field.
/// [onChanged] is called when either field text changes (for parent setState).
/// [onRemove] is called when the remove button is tapped (null hides button).
class AttributeRowWidget extends StatelessWidget {
  final TextEditingController keyController;
  final TextEditingController valueController;
  final bool isPredefined;
  final Set<String> knownKeyNames;
  final List<String> valueSuggestions;
  final VoidCallback? onChanged;
  final VoidCallback? onRemove;

  const AttributeRowWidget({
    super.key,
    required this.keyController,
    required this.valueController,
    this.isPredefined = false,
    required this.knownKeyNames,
    this.valueSuggestions = const [],
    this.onChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final keyText = keyController.text.trim();
    final valueText = valueController.text.trim();

    final isKeyNew = !isPredefined &&
        keyText.isNotEmpty &&
        !knownKeyNames.contains(keyText.toLowerCase());

    final isValueNew = valueText.isNotEmpty &&
        !valueSuggestions
            .map((s) => s.toLowerCase())
            .contains(valueText.toLowerCase());

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attribute Key Field
          Expanded(
            flex: 1,
            child: Autocomplete<String>(
              initialValue: TextEditingValue(text: keyController.text),
              optionsBuilder: (TextEditingValue textVal) {
                if (isPredefined) return const [];
                final q = textVal.text.toLowerCase();
                return knownKeyNames.where((k) => k.toLowerCase().contains(q));
              },
              onSelected: (val) {
                keyController.text = val;
                onChanged?.call();
              },
              fieldViewBuilder: (context, ctrl, focusNode, onSubmitted) {
                return TextFormField(
                  controller: ctrl,
                  focusNode: focusNode,
                  readOnly: isPredefined,
                  decoration: InputDecoration(
                    labelText: isPredefined ? keyController.text : 'Attribute Key',
                    hintText: 'e.g. Color',
                    suffixIcon: isKeyNew ? const NewBadge() : null,
                  ),
                  onChanged: (val) {
                    keyController.text = val;
                    onChanged?.call();
                  },
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.base),

          // Attribute Value Field
          Expanded(
            flex: 1,
            child: Autocomplete<String>(
              initialValue: TextEditingValue(text: valueController.text),
              optionsBuilder: (TextEditingValue textVal) {
                final q = textVal.text.toLowerCase();
                return valueSuggestions.where(
                  (v) => v.toLowerCase().contains(q),
                );
              },
              onSelected: (val) {
                valueController.text = val;
                onChanged?.call();
              },
              fieldViewBuilder: (context, ctrl, focusNode, onSubmitted) {
                return TextFormField(
                  controller: ctrl,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Value',
                    hintText: 'e.g. Red',
                    suffixIcon: isValueNew ? const NewBadge() : null,
                  ),
                  onChanged: (val) {
                    valueController.text = val;
                    onChanged?.call();
                  },
                );
              },
            ),
          ),

          if (onRemove != null)
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: AppColors.error,
              ),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
