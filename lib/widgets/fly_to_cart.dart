import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/state/providers.dart';
import '../core/utils/context_ext.dart';
import 'app_image.dart';
import 'badges.dart';

/// Cart icon with a count badge that bounces whenever the count goes up.
/// Each instance registers itself as a "fly to cart" landing target.
class CartIconButton extends ConsumerStatefulWidget {
  const CartIconButton({super.key, this.color});
  final Color? color;

  @override
  ConsumerState<CartIconButton> createState() => _CartIconButtonState();
}

class _CartIconButtonState extends ConsumerState<CartIconButton> with SingleTickerProviderStateMixin {
  final _key = GlobalKey();
  late final _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  late final _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.35), weight: 40),
    TweenSequenceItem(tween: Tween<double>(begin: 1.35, end: 0.92), weight: 30),
    TweenSequenceItem(tween: Tween<double>(begin: 0.92, end: 1), weight: 30),
  ]).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    FlyToCart._targets.add(_key);
  }

  @override
  void dispose() {
    FlyToCart._targets.remove(_key);
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(cartCountProvider, (prev, next) {
      if (next > (prev ?? 0)) _bounce.forward(from: 0);
    });
    final count = ref.watch(cartCountProvider);
    return IconButton(
      key: _key,
      tooltip: context.l10n.cart,
      onPressed: () => context.push('/cart'),
      icon: ScaleTransition(
        scale: _scale,
        child: CountBadge(
          count: count,
          child: Icon(Icons.shopping_cart_outlined, color: widget.color),
        ),
      ),
    );
  }
}

abstract final class FlyToCart {
  static final List<GlobalKey> _targets = [];

  /// Animates a thumbnail from [fromKey]'s position to the most recently
  /// mounted cart icon, then calls [onArrive]. Falls back to calling
  /// [onArrive] immediately when no target is visible.
  static void run(
    BuildContext context, {
    required GlobalKey fromKey,
    required String image,
    required VoidCallback onArrive,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final fromBox = fromKey.currentContext?.findRenderObject() as RenderBox?;
    final target = _targets.reversed
        .map((k) => k.currentContext?.findRenderObject() as RenderBox?)
        .firstWhere((b) => b != null && b.attached && b.hasSize, orElse: () => null);
    if (fromBox == null || target == null) {
      onArrive();
      return;
    }
    final start = fromBox.localToGlobal(fromBox.size.center(Offset.zero));
    final end = target.localToGlobal(target.size.center(Offset.zero));
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Flyer(
        start: start,
        end: end,
        image: image,
        onDone: () {
          entry.remove();
          onArrive();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _Flyer extends StatefulWidget {
  const _Flyer({required this.start, required this.end, required this.image, required this.onDone});

  final Offset start;
  final Offset end;
  final String image;
  final VoidCallback onDone;

  @override
  State<_Flyer> createState() => _FlyerState();
}

class _FlyerState extends State<_Flyer> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
    ..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeInOutCubic.transform(_c.value);
          // Quadratic bezier with a control point above the path → arc.
          final control = Offset((widget.start.dx + widget.end.dx) / 2, widget.start.dy - 220);
          final p = Offset(
            (1 - t) * (1 - t) * widget.start.dx + 2 * (1 - t) * t * control.dx + t * t * widget.end.dx,
            (1 - t) * (1 - t) * widget.start.dy + 2 * (1 - t) * t * control.dy + t * t * widget.end.dy,
          );
          final size = 64 * (1 - 0.7 * t);
          return Stack(
            children: [
              Positioned(
                left: p.dx - size / 2,
                top: p.dy - size / 2,
                child: Opacity(
                  opacity: 1 - 0.3 * t,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                    ),
                    child: ClipOval(child: AppImage(widget.image)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
