import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme/tokens.dart';
import '../core/utils/context_ext.dart';
import 'buttons.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.textInputAction,
    this.maxLength,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        readOnly: readOnly,
        onTap: onTap,
        inputFormatters: inputFormatters,
        textInputAction: textInputAction,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}

/// Rounded search bar. When [onTap] is set it acts as a button that opens
/// the global search screen; otherwise it's an editable field.
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.hint,
    this.onTap,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.onMic,
    this.trailing,
    this.elevated = true,
  });

  final String hint;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final VoidCallback? onMic;
  final Widget? trailing;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final field = onTap != null
        ? Text(
            hint,
            style: context.text.bodyMedium?.copyWith(color: p.muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : TextField(
            controller: controller,
            autofocus: autofocus,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          );
    final bar = Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.only(left: Gap.md),
      decoration: BoxDecoration(
        color: p.isDark ? p.surfaceAlt : p.surface,
        borderRadius: Radii.buttonBorder,
        border: Border.all(color: p.border),
        boxShadow: elevated ? softShadow(p.isDark) : null,
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: p.muted, semanticLabel: context.l10n.search),
          const SizedBox(width: Gap.sm),
          Expanded(child: field),
          ?trailing,
          if (onMic != null)
            IconButton(
              tooltip: context.l10n.voiceHint,
              onPressed: onMic,
              icon: Icon(Icons.mic_rounded, color: p.primary),
            ),
        ],
      ),
    );
    if (onTap == null) return bar;
    return Semantics(
      button: true,
      label: hint,
      child: PressableScale(onTap: onTap, child: bar),
    );
  }
}

/// Horizontally scrolling single-select chips.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.labelOf,
    this.padding,
    this.color,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final String Function(String)? labelOf;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = color ?? p.primary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: Gap.lg),
      child: Row(
        children: [
          for (final o in options)
            Padding(
              padding: const EdgeInsets.only(right: Gap.sm),
              child: ChoiceChip(
                label: Text(labelOf?.call(o) ?? o),
                selected: o == selected,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  onSelected(o);
                },
                selectedColor: c,
                labelStyle: context.text.labelMedium?.copyWith(
                  color: o == selected ? Colors.white : p.text,
                  fontWeight: o == selected ? FontWeight.w600 : FontWeight.w500,
                ),
                side: BorderSide(color: o == selected ? c : p.border),
              ),
            ),
        ],
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.dense = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final size = dense ? 32.0 : 40.0;
    Widget btn(IconData icon, bool enabled, int delta, String label) => Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onChanged(value + delta);
              }
            : null,
        child: SizedBox.square(
          dimension: size,
          child: Icon(icon, size: dense ? 16 : 20, color: enabled ? p.text : p.border),
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, value > min, -1, 'Decrease'),
          AnimatedSwitcher(
            duration: Motion.fast,
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: SizedBox(
              key: ValueKey(value),
              width: dense ? 28 : 36,
              child: Text(context.digits(value), textAlign: TextAlign.center, style: context.text.titleSmall),
            ),
          ),
          btn(Icons.add_rounded, value < max, 1, 'Increase'),
        ],
      ),
    );
  }
}

/// Read-only field that opens a picker (date, time, list) when tapped.
class PickerField extends StatelessWidget {
  const PickerField({super.key, required this.label, required this.value, required this.onTap, this.icon});

  final String label;
  final String? value;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: Semantics(
        button: true,
        label: '$label ${value ?? ''}',
        excludeSemantics: true,
        child: InkWell(
          borderRadius: Radii.buttonBorder,
          onTap: onTap,
          child: InputDecorator(
            isEmpty: value == null || value!.isEmpty,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: icon == null ? null : Icon(icon),
              suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
            ),
            child: Text(value ?? '', style: context.text.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}
