import 'package:material_ui/material_ui.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/tokens.dart';
import '../core/utils/context_ext.dart';

// ---------------------------------------------------------------- Shimmer

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.width, this.height, this.radius = 0});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Shimmer.fromColors(
      baseColor: p.isDark ? const Color(0xFF222C31) : const Color(0xFFE9ECEF),
      highlightColor: p.isDark ? const Color(0xFF2E3A40) : const Color(0xFFF8F9FA),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}

/// Skeletons that mirror the real list/grid layouts.
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer.list({super.key, this.count = 6}) : grid = false, columns = 1;
  const LoadingShimmer.grid({super.key, this.count = 6, this.columns = 2}) : grid = true;

  final int count;
  final bool grid;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final pad = EdgeInsets.all(Gap.lg);
    if (grid) {
      return GridView.builder(
        padding: pad,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: Gap.md,
          crossAxisSpacing: Gap.md,
          childAspectRatio: 0.62,
        ),
        itemBuilder: (_, _) => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 1, child: ShimmerBox(radius: Radii.card)),
            SizedBox(height: Gap.sm),
            ShimmerBox(height: 12, radius: 4),
            SizedBox(height: Gap.xs),
            ShimmerBox(height: 12, width: 90, radius: 4),
            SizedBox(height: Gap.sm),
            ShimmerBox(height: 16, width: 60, radius: 4),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: pad,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
      itemBuilder: (_, _) => const Row(
        children: [
          ShimmerBox(width: 64, height: 64, radius: Radii.button),
          SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14, radius: 4),
                SizedBox(height: Gap.sm),
                ShimmerBox(height: 12, width: 140, radius: 4),
                SizedBox(height: Gap.sm),
                ShimmerBox(height: 12, width: 80, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a skeleton briefly before the real content, simulating a network
/// load so every list demonstrates its loading state.
class DemoLoader extends StatefulWidget {
  const DemoLoader({
    super.key,
    required this.builder,
    this.skeleton = const LoadingShimmer.list(),
    this.delay = const Duration(milliseconds: 650),
  });

  final WidgetBuilder builder;
  final Widget skeleton;
  final Duration delay;

  @override
  State<DemoLoader> createState() => _DemoLoaderState();
}

class _DemoLoaderState extends State<DemoLoader> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Motion.medium,
      child: _loading
          ? KeyedSubtree(key: const ValueKey('s'), child: widget.skeleton)
          : KeyedSubtree(key: const ValueKey('c'), child: widget.builder(context)),
    );
  }
}

// ---------------------------------------------------------------- States

/// Friendly empty state with a layered "illustration" built from icons.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.color,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = color ?? p.primary;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Gap.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(color: c.withValues(alpha: 0.08), shape: BoxShape.circle),
                  ),
                  Positioned(top: 8, right: 14, child: Icon(Icons.auto_awesome_rounded, color: p.secondary, size: 22)),
                  Positioned(
                    bottom: 14,
                    left: 10,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(color: p.secondary.withValues(alpha: 0.4), shape: BoxShape.circle),
                    ),
                  ),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: p.surface,
                      shape: BoxShape.circle,
                      boxShadow: softShadow(p.isDark),
                      border: p.isDark ? Border.all(color: p.border) : null,
                    ),
                    child: Icon(icon, size: 38, color: c),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.lg),
            Text(title, style: context.text.titleLarge, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: Gap.sm),
              Text(
                message!,
                style: context.text.bodyMedium?.copyWith(color: p.muted),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: Gap.xl),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      color: context.palette.emergency,
      title: context.l10n.errorTitle,
      message: context.l10n.errorBody,
      actionLabel: context.l10n.retry,
      onAction: onRetry,
    );
  }
}

// ---------------------------------------------------------------- Refresh

/// Pull-to-refresh with a custom branded indicator (a rotating leaf badge
/// that slides in from the top) instead of the stock spinner.
class AppRefresh extends StatefulWidget {
  const AppRefresh({super.key, required this.child, this.onRefresh});

  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  State<AppRefresh> createState() => _AppRefreshState();
}

class _AppRefreshState extends State<AppRefresh> with SingleTickerProviderStateMixin {
  late final _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  RefreshIndicatorStatus? _status;

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _onStatus(RefreshIndicatorStatus? s) {
    setState(() => _status = s);
    if (s == RefreshIndicatorStatus.refresh) {
      _spin.repeat();
    } else if (s == RefreshIndicatorStatus.done || s == RefreshIndicatorStatus.canceled) {
      _spin.stop();
    }
  }

  Future<void> _refresh() async {
    await (widget.onRefresh?.call() ?? Future.delayed(const Duration(milliseconds: 1100)));
    if (mounted) context.toast(context.l10n.pullToRefresh);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final visible =
        _status == RefreshIndicatorStatus.armed ||
        _status == RefreshIndicatorStatus.snap ||
        _status == RefreshIndicatorStatus.refresh ||
        _status == RefreshIndicatorStatus.drag;
    return Stack(
      children: [
        RefreshIndicator.noSpinner(onRefresh: _refresh, onStatusChange: _onStatus, child: widget.child),
        Positioned(
          top: MediaQuery.paddingOf(context).top + Gap.md,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: AnimatedSlide(
              offset: visible ? Offset.zero : const Offset(0, -2),
              duration: Motion.medium,
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: Motion.fast,
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: p.surface,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10)],
                    ),
                    child: RotationTransition(
                      turns: _spin,
                      child: AnimatedScale(
                        scale: _status == RefreshIndicatorStatus.armed || _status == RefreshIndicatorStatus.refresh
                            ? 1.1
                            : 0.85,
                        duration: Motion.fast,
                        child: Icon(Icons.eco_rounded, color: p.primary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
