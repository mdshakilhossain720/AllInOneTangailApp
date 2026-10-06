import 'package:material_ui/material_ui.dart';

import '../core/utils/context_ext.dart';

/// ৳ price with optional strikethrough old price. Uses Bangla digits when the
/// UI language is Bangla.
class PriceText extends StatelessWidget {
  const PriceText(this.price, {super.key, this.oldPrice, this.size = PriceSize.medium, this.color});

  final num price;
  final num? oldPrice;
  final PriceSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final main = switch (size) {
      PriceSize.small => context.text.titleSmall,
      PriceSize.medium => context.text.titleMedium,
      PriceSize.large => context.text.headlineMedium,
    };
    final current = Text(
      context.taka(price),
      maxLines: 1,
      // Darker orange in light mode keeps AA contrast on white.
      style: main?.copyWith(
        color: color ?? (p.isDark ? p.secondary : const Color(0xFFC2611A)),
        fontWeight: FontWeight.w700,
      ),
    );
    final hasOld = oldPrice != null && oldPrice! > price;
    // Single line: the old price shrinks/ellipsizes rather than wrapping, so
    // fixed-height cards never overflow.
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: current),
        ),
        if (hasOld) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              context.taka(oldPrice!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(decoration: TextDecoration.lineThrough, color: p.muted),
            ),
          ),
        ],
      ],
    );
  }
}

enum PriceSize { small, medium, large }

class RatingStars extends StatelessWidget {
  const RatingStars(this.rating, {super.key, this.size = 14, this.count, this.showValue = true});

  final double rating;
  final double size;
  final int? count;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF5B301);
    return Semantics(
      label: '${context.l10n.rating} ${rating.toStringAsFixed(1)} ${context.l10n.outOf5}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              rating >= i
                  ? Icons.star_rounded
                  : rating >= i - 0.5
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
              size: size,
              color: amber,
            ),
          if (showValue) ...[
            const SizedBox(width: 4),
            Text(context.digits(rating.toStringAsFixed(1)), style: context.text.labelMedium),
          ],
          if (count != null) ...[
            const SizedBox(width: 2),
            Flexible(child: Text('(${context.compact(count!)})', style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ],
      ),
    );
  }
}

/// Compact "★ 4.8" label.
class RatingLabel extends StatelessWidget {
  const RatingLabel(this.rating, {super.key, this.suffix});
  final double rating;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF5B301)),
        const SizedBox(width: 2),
        Text(context.digits(rating.toStringAsFixed(1)), style: context.text.labelMedium),
        if (suffix != null) ...[
          const SizedBox(width: 4),
          Flexible(
            child: Text(suffix!, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ],
    );
  }
}
