import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/responsive/responsive.dart';
import '../core/state/providers.dart';
import '../core/theme/tokens.dart';
import '../core/utils/context_ext.dart';
import '../data/demo/common_data.dart';
import '../data/models.dart';
import 'app_image.dart';
import 'badges.dart';
import 'buttons.dart';
import 'price.dart';

void openProduct(BuildContext context, WidgetRef ref, String id, {String? heroScope}) {
  ref.read(recentlyViewedProvider.notifier).push(id, max: 10);
  context.push(heroScope == null ? '/shop/product/$id' : '/shop/product/$id?h=$heroScope');
}

/// Hero tag for a product image; [scope] keeps tags unique when the same
/// product appears in several lists on one page.
String productHero(String id, [String? scope]) => scope == null ? 'product-$id' : 'product-$scope-$id';

/// Grid product card: image, wishlist heart, discount badge, 2-line name,
/// ৳ price with strikethrough, rating + sold, upazila, verified.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product, this.onTap, this.selected = false, this.heroScope});

  final Product product;
  final String? heroScope;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final pr = product;
    return Semantics(
      button: true,
      label: '${pr.name}, ${context.taka(pr.price)}',
      child: PressableScale(
        onTap: onTap ?? () => openProduct(context, ref, pr.id, heroScope: heroScope),
        child: Container(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: Radii.cardBorder,
            boxShadow: softShadow(p.isDark),
            border: selected
                ? Border.all(color: p.primary, width: 1.5)
                : (p.isDark ? Border.all(color: p.border) : null),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(tag: productHero(pr.id, heroScope), child: AppImage(pr.images.first)),
                    if (pr.discountPct != null) Positioned(top: 0, left: 0, child: DiscountBadge(pr.discountPct!)),
                    Positioned(top: -4, right: -4, child: HeartButton(productId: pr.id, size: 18)),
                    if (pr.stock == 0)
                      Container(
                        color: Colors.black45,
                        alignment: Alignment.center,
                        child: Pill(context.l10n.outOfStock, color: Colors.black87, solid: true),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.sm + 2, Gap.sm, Gap.sm + 2, Gap.sm + 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pr.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(height: 1.3),
                    ),
                    const SizedBox(height: Gap.xs),
                    PriceText(pr.price, oldPrice: pr.oldPrice, size: PriceSize.small),
                    const SizedBox(height: Gap.xs),
                    RatingLabel(pr.rating, suffix: '· ${context.l10n.sold(context.compact(pr.sold))}'),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: p.muted),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            upazilaName(pr.upazila).of(context),
                            style: context.text.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (pr.verified) const VerifiedBadge(compact: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal list-mode product row.
class ProductListTile extends ConsumerWidget {
  const ProductListTile({super.key, required this.product, this.onTap, this.selected = false});

  final Product product;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final pr = product;
    return PressableScale(
      onTap: onTap ?? () => openProduct(context, ref, pr.id),
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: Radii.cardBorder,
          boxShadow: softShadow(p.isDark),
          border: selected ? Border.all(color: p.primary, width: 1.5) : (p.isDark ? Border.all(color: p.border) : null),
        ),
        padding: const EdgeInsets.all(Gap.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 104,
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: productHero(pr.id),
                      child: AppImage(pr.images.first, radius: Radii.button),
                    ),
                    if (pr.discountPct != null) Positioned(top: 0, left: 0, child: DiscountBadge(pr.discountPct!)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pr.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                  const SizedBox(height: Gap.xs),
                  PriceText(pr.price, oldPrice: pr.oldPrice, size: PriceSize.small),
                  const SizedBox(height: Gap.xs),
                  RatingLabel(pr.rating, suffix: '· ${context.l10n.sold(context.compact(pr.sold))}'),
                  const SizedBox(height: Gap.xs),
                  Wrap(
                    spacing: Gap.xs,
                    runSpacing: Gap.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Pill(
                        upazilaName(pr.upazila).of(context),
                        color: p.muted,
                        icon: Icons.location_on_outlined,
                        dense: true,
                      ),
                      if (pr.verified) const VerifiedBadge(),
                      if (pr.pickup) Pill(context.l10n.localPickup, color: p.success, dense: true),
                    ],
                  ),
                ],
              ),
            ),
            HeartButton(productId: pr.id, filledBackground: false),
          ],
        ),
      ),
    );
  }
}

/// Fixed-width product card for horizontal carousels.
class ProductCarousel extends StatelessWidget {
  const ProductCarousel({super.key, required this.products, required this.heroScope, this.padding});

  final List<Product> products;
  final String heroScope;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    // Card height = square image + text block (scaled with font size).
    const width = 156.0;
    final height = width + context.scaled(144);
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: 2),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: Gap.md),
        itemBuilder: (_, i) => SizedBox(
          width: width,
          child: ProductCard(product: products[i], heroScope: heroScope),
        ),
      ),
    );
  }
}
