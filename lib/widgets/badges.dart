import 'package:material_ui/material_ui.dart';

import '../core/theme/tokens.dart';
import '../core/utils/context_ext.dart';

/// Small rounded label used for statuses and tags.
class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, required this.color, this.icon, this.solid = false, this.dense = false});

  final String label;
  final Color color;
  final IconData? icon;
  final bool solid;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final fg = solid ? Colors.white : color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 6 : 8, vertical: dense ? 1 : 3),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: context.palette.isDark ? 0.22 : 0.12),
        borderRadius: Radii.chipBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: dense ? 11 : 13, color: fg), const SizedBox(width: 3)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class DiscountBadge extends StatelessWidget {
  const DiscountBadge(this.percent, {super.key});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.palette.emergency,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Text(
        context.l10n.off(context.digits(percent)),
        style: context.text.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.palette.info;
    if (compact) {
      return Tooltip(
        message: context.l10n.verified,
        child: Icon(Icons.verified_rounded, size: 16, color: c, semanticLabel: context.l10n.verified),
      );
    }
    return Pill(context.l10n.verified, color: c, icon: Icons.verified_rounded, dense: true);
  }
}

class OpenBadge extends StatelessWidget {
  const OpenBadge({super.key, required this.isOpen, this.is24h = false});
  final bool isOpen;
  final bool is24h;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (is24h) return Pill(context.l10n.open24h, color: p.success, icon: Icons.schedule_rounded, dense: true);
    return Pill(
      isOpen ? context.l10n.open : context.l10n.closed,
      color: isOpen ? p.success : p.emergency,
      icon: Icons.circle,
      dense: true,
    );
  }
}

enum StatusTone { success, warning, danger, info, neutral, primary }

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.tone = StatusTone.neutral, this.icon});

  final String label;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = switch (tone) {
      StatusTone.success => p.success,
      StatusTone.warning => const Color(0xFFB7880B),
      StatusTone.danger => p.emergency,
      StatusTone.info => p.info,
      StatusTone.primary => p.primary,
      StatusTone.neutral => p.muted,
    };
    return Pill(label, color: color, icon: icon);
  }
}

/// "DEMO" badge shown in app bars.
class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key, this.onDark = false});
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Demo build',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Gap.xs),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: onDark ? Colors.white.withValues(alpha: 0.2) : context.palette.secondarySoft,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: onDark ? Colors.white54 : context.palette.secondary),
        ),
        child: Text(
          context.l10n.demo,
          style: context.text.labelSmall?.copyWith(
            color: onDark ? Colors.white : const Color(0xFFB4621B),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

/// Count badge for icons (cart, notifications).
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, required this.child});
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      backgroundColor: context.palette.emergency,
      label: Text(context.digits(count > 99 ? '99+' : '$count')),
      child: child,
    );
  }
}
