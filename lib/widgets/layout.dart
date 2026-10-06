import 'package:material_ui/material_ui.dart';

import '../core/responsive/responsive.dart';
import '../core/theme/tokens.dart';
import '../core/utils/context_ext.dart';
import 'badges.dart';

/// Standard page scaffold: app bar with DEMO badge, safe body, optional
/// sticky bottom bar. Content width is capped on large screens.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.titleWidget,
    required this.body,
    this.actions = const [],
    this.bottomBar,
    this.floatingActionButton,
    this.bottom,
    this.showDemo = true,
    this.maxWidth = true,
    this.backgroundColor,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget body;
  final List<Widget> actions;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;
  final bool showDemo;
  final bool maxWidth;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title:
            titleWidget ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (showDemo) const DemoBadge(),
              ],
            ),
        actions: [
          ...actions,
          const SizedBox(width: Gap.xs),
        ],
        bottom: bottom,
      ),
      body: SafeArea(
        top: false,
        bottom: bottomBar == null,
        child: maxWidth ? MaxWidth(child: body) : body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar == null ? null : StickyBar(child: bottomBar!),
    );
  }
}

/// Bottom action bar with a top border/shadow and safe-area padding.
class StickyBar extends StatelessWidget {
  const StickyBar({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
        boxShadow: p.isDark
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.lg, Gap.md),
          child: MaxWidth(child: child),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.onSeeAll, this.trailing, this.padding, this.icon});

  final String title;
  final VoidCallback? onSeeAll;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(context.pagePadding, Gap.xl, context.pagePadding - 4, Gap.sm),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 20, color: context.palette.primary), const SizedBox(width: Gap.sm)],
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: context.text.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          if (trailing != null) Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: trailing)),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: Gap.sm)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text(context.l10n.seeAll), const Icon(Icons.chevron_right_rounded, size: 18)],
              ),
            ),
        ],
      ),
    );
  }
}

/// Surface card: soft shadow in light mode, border in dark mode.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Gap.lg),
    this.color,
    this.radius = Radii.card,
    this.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: r,
        boxShadow: softShadow(p.isDark),
        border: border ?? (p.isDark ? Border.all(color: p.border) : null),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: r,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Icon inside a pastel rounded square.
class PastelIcon extends StatelessWidget {
  const PastelIcon(this.icon, {super.key, required this.index, this.size = 48, this.iconSize});

  final IconData icon;
  final int index;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = context.palette.pastel(index);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.3)),
      child: Icon(icon, color: fg, size: iconSize ?? size * 0.5),
    );
  }
}

/// Generic list card: leading visual, title, subtitle lines, chips, trailing.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.meta = const [],
    this.chips = const [],
    this.trailing,
    this.onTap,
    this.selected = false,
  });

  final String title;
  final Widget? leading;
  final String? subtitle;
  final List<(IconData, String)> meta;
  final List<Widget> chips;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Gap.md),
      border: selected ? Border.all(color: p.primary, width: 1.5) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: Gap.md)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: context.text.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                for (final (icon, text) in meta) ...[
                  const SizedBox(height: Gap.xs),
                  Row(
                    children: [
                      Icon(icon, size: 14, color: p.muted),
                      const SizedBox(width: Gap.xs),
                      Expanded(
                        child: Text(text, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: Gap.sm),
                  Wrap(spacing: Gap.xs, runSpacing: Gap.xs, children: chips),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: Gap.sm), trailing!],
        ],
      ),
    );
  }
}

/// Label/value row used in detail screens and order summaries.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow(this.label, this.value, {super.key, this.bold = false, this.valueColor});

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = bold ? context.text.titleMedium : context.text.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: style?.copyWith(color: bold ? null : context.palette.muted)),
          ),
          const SizedBox(width: Gap.md),
          Flexible(
            child: Text(
              value,
              style: style?.copyWith(color: valueColor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Text that collapses to [maxLines] with a "Read more" toggle.
class ReadMoreText extends StatefulWidget {
  const ReadMoreText(this.text, {super.key, this.maxLines = 3, this.style});
  final String text;
  final int maxLines;
  final TextStyle? style;

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? context.text.bodyMedium;
    return LayoutBuilder(
      builder: (context, c) {
        final tp = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: widget.maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: c.maxWidth);
        final overflows = tp.didExceedMaxLines;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: Motion.medium,
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: style,
                maxLines: _expanded ? null : widget.maxLines,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
            ),
            if (overflows || _expanded)
              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(48, 40)),
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? context.l10n.showLess : context.l10n.readMore),
              ),
          ],
        );
      },
    );
  }
}

/// Sliver-friendly page padding helper.
EdgeInsets pagePad(BuildContext context, {double top = 0, double bottom = 0}) =>
    EdgeInsets.fromLTRB(context.pagePadding, top, context.pagePadding, bottom);

/// Opens a standard bottom sheet that is scroll-safe and keyboard-aware.
Future<T?> showAppSheet<T>(BuildContext context, {required WidgetBuilder builder, bool scrollable = true}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: scrollable
          ? SingleChildScrollView(padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl), child: builder(ctx))
          : builder(ctx),
    ),
  );
}

/// Title row used at the top of bottom sheets.
class SheetTitle extends StatelessWidget {
  const SheetTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.headlineSmall),
          if (subtitle != null) ...[
            const SizedBox(height: Gap.xs),
            Text(subtitle!, style: context.text.bodyMedium?.copyWith(color: context.palette.muted)),
          ],
        ],
      ),
    );
  }
}
