import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/state/providers.dart';
import '../core/theme/tokens.dart';
import '../core/utils/context_ext.dart';

/// Scales its child to 0.97 while pressed.
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.onTap, this.onLongPress, this.scale = 0.97});

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null && widget.onLongPress == null) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: Motion.fast,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Full-width filled button with press scale and optional loading state.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.color,
    this.expand = true,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final Color? color;
  final bool expand;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: Gap.sm)],
              Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          );
    final onTap = loading ? null : onPressed;
    final button = outlined
        ? OutlinedButton(
            onPressed: onTap,
            style: color == null
                ? null
                : OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color!),
                  ),
            child: child,
          )
        : FilledButton(
            onPressed: onTap,
            style: color == null ? null : FilledButton.styleFrom(backgroundColor: color),
            child: child,
          );
    return PressableScale(
      onTap: onTap == null ? null : () {},
      child: SizedBox(width: expand ? double.infinity : null, child: button),
    );
  }
}

/// Shows a confirm sheet, then a demo "calling" snackbar.
Future<void> confirmCall(BuildContext context, {required String name, required String number}) async {
  final l = context.l10n;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: ctx.palette.primarySoft,
              child: Icon(Icons.call_rounded, color: ctx.palette.primary, size: 30),
            ),
            const SizedBox(height: Gap.lg),
            Text(l.callConfirmTitle(name), style: ctx.text.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: Gap.xs),
            Text(ctx.digits(number), style: ctx.text.bodyLarge?.copyWith(color: ctx.palette.muted)),
            const SizedBox(height: Gap.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(ctx, true),
                    icon: const Icon(Icons.call_rounded),
                    label: Text(l.callNow),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (ok == true && context.mounted) {
    HapticFeedback.mediumImpact();
    context.toast(l.callingDemo(context.digits(number)));
  }
}

/// Green round call button (48px tap target) or a labelled variant.
class CallButton extends StatelessWidget {
  const CallButton({super.key, required this.name, required this.number, this.label, this.color});

  final String name;
  final String number;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.palette.success;
    void onTap() => confirmCall(context, name: name, number: number);
    if (label != null) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: c),
        onPressed: onTap,
        icon: const Icon(Icons.call_rounded, size: 18),
        label: Text(label!),
      );
    }
    return IconButton.filled(
      tooltip: '${context.l10n.call} $name',
      style: IconButton.styleFrom(backgroundColor: c.withValues(alpha: 0.12), foregroundColor: c),
      onPressed: onTap,
      icon: const Icon(Icons.call_rounded, size: 20),
    );
  }
}

/// Heart with a "pop" animation, bound to the wishlist.
class HeartButton extends ConsumerStatefulWidget {
  const HeartButton({super.key, required this.productId, this.size = 20, this.filledBackground = true});

  final String productId;
  final double size;
  final bool filledBackground;

  @override
  ConsumerState<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends ConsumerState<HeartButton> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  late final _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.4).chain(CurveTween(curve: Curves.easeOut)), weight: 45),
    TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 0.9), weight: 25),
    TweenSequenceItem(tween: Tween<double>(begin: 0.9, end: 1), weight: 30),
  ]).animate(_c);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liked = ref.watch(wishlistProvider).contains(widget.productId);
    final p = context.palette;
    return Semantics(
      button: true,
      label: context.l10n.wishlist,
      toggled: liked,
      child: InkResponse(
        radius: 24,
        onTap: () {
          HapticFeedback.lightImpact();
          final added = ref.read(wishlistProvider.notifier).toggle(widget.productId);
          if (added) _c.forward(from: 0);
        },
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: widget.filledBackground
                  ? BoxDecoration(color: p.surface.withValues(alpha: 0.92), shape: BoxShape.circle)
                  : null,
              child: ScaleTransition(
                scale: _scale,
                child: Icon(
                  liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: widget.size,
                  color: liked ? p.emergency : p.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bookmark toggle for doctors, lawyers, businesses and places.
class SaveButton extends ConsumerWidget {
  const SaveButton({super.key, required this.kind, required this.id, this.color});

  final SavedKind kind;
  final String id;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedProvider)[kind]?.contains(id) ?? false;
    return IconButton(
      tooltip: context.l10n.save,
      isSelected: saved,
      onPressed: () {
        HapticFeedback.selectionClick();
        final added = ref.read(savedProvider.notifier).toggle(kind, id);
        context.toast(added ? context.l10n.addedToSaved : context.l10n.removedFromSaved);
      },
      icon: AnimatedSwitcher(
        duration: Motion.fast,
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
        child: Icon(
          saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          key: ValueKey(saved),
          color: saved ? context.palette.primary : color,
        ),
      ),
    );
  }
}
