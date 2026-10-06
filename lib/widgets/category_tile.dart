import 'package:material_ui/material_ui.dart';

import '../core/theme/tokens.dart';
import '../core/utils/context_ext.dart';
import 'buttons.dart';
import 'layout.dart';

/// Pastel icon + label, used in category grids.
class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.icon, required this.label, required this.index, this.onTap});

  final IconData icon;
  final String label;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: PressableScale(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Gap.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PastelIcon(icon, index: index, size: 52),
              const SizedBox(height: Gap.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelMedium?.copyWith(height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Red outlined chip with a call icon (emergency quick row).
class EmergencyChip extends StatelessWidget {
  const EmergencyChip({super.key, required this.label, required this.number, required this.icon});

  final String label;
  final String number;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.palette.emergency;
    return Semantics(
      button: true,
      label: '${context.l10n.call} $label $number',
      excludeSemantics: true,
      child: PressableScale(
        onTap: () => confirmCall(context, name: label, number: number),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
          decoration: BoxDecoration(
            color: context.palette.emergencySoft,
            borderRadius: Radii.chipBorder,
            border: Border.all(color: c.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: c),
              const SizedBox(width: 6),
              Text(label, style: context.text.labelLarge?.copyWith(color: c)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                child: const Icon(Icons.call_rounded, size: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
