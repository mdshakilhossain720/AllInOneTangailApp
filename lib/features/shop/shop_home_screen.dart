import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/shop_data.dart';
import '../../data/models.dart';
import '../../widgets/widgets.dart';
import '../home/home_screen.dart' show flashSaleEnds;

class ShopHomeScreen extends ConsumerWidget {
  const ShopHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final pad = context.pagePadding;
    final recent = ref.watch(recentlyViewedProvider);
    return Scaffold(
      body: AppRefresh(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(l.navShop, overflow: TextOverflow.ellipsis)),
                  const DemoBadge(),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: l.wishlist,
                  onPressed: () => context.push('/saved'),
                  icon: const Icon(Icons.favorite_border_rounded),
                ),
                IconButton(
                  tooltip: l.myOrders,
                  onPressed: () => context.push('/orders'),
                  icon: const Icon(Icons.receipt_long_outlined),
                ),
                const CartIconButton(),
                const SizedBox(width: Gap.xs),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(context.scaled(50) + Gap.md),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 0, pad, Gap.md),
                  child: MaxWidth(
                    child: SearchBarWidget(
                      hint: l.shopSearchHint,
                      elevated: false,
                      onTap: () => context.push('/shop/products?focus=1'),
                      trailing: IconButton(
                        tooltip: l.voiceHint,
                        onPressed: () => context.push('/search?voice=1'),
                        icon: Icon(Icons.mic_rounded, color: p.primary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MaxWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Gap.md),
                    const _ShopCategories(),
                    Padding(padding: EdgeInsets.fromLTRB(pad, Gap.lg, pad, 0), child: const _ShopBanner()),
                    SectionHeader(
                      l.flashSale,
                      icon: Icons.bolt_rounded,
                      trailing: CountdownTimer(target: flashSaleEnds, compact: true),
                      onSeeAll: () => context.push('/shop/products?flash=1'),
                    ),
                    ProductCarousel(
                      heroScope: 'shop-flash',
                      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 2),
                      products: [for (final id in flashSaleIds) productById(id)],
                    ),
                    _MadeInTangail(pad: pad),
                    SectionHeader(l.topSellers, onSeeAll: () => context.push('/shop/products')),
                    SizedBox(
                      height: context.scaled(150),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: pad, vertical: 2),
                        itemCount: stores.length,
                        separatorBuilder: (_, _) => const SizedBox(width: Gap.md),
                        itemBuilder: (_, i) => _StoreChip(store: stores[i]),
                      ),
                    ),
                    if (recent.isNotEmpty) ...[
                      SectionHeader(l.recentlyViewed),
                      ProductCarousel(
                        heroScope: 'recent',
                        padding: EdgeInsets.symmetric(horizontal: pad, vertical: 2),
                        products: [for (final id in recent) resolveProduct(ref, id)],
                      ),
                    ],
                    SectionHeader(l.recommended),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              sliver: SliverLayoutBuilder(
                builder: (context, c) {
                  final w = c.crossAxisExtent.clamp(0.0, AppBreakpoints.maxContent);
                  return SliverGrid.builder(
                    gridDelegate: productGridDelegate(context, w),
                    itemCount: products.length,
                    itemBuilder: (_, i) => ProductCard(product: products[i], heroScope: 'rec'),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

/// Product grid: 2 → 3 → 4 columns, height derived from card width + the
/// text block (scaled with system font size).
SliverGridDelegate productGridDelegate(BuildContext context, double width) {
  final cols = AppBreakpoints.productColumns(width);
  final cardW = (width - (cols - 1) * Gap.md) / cols;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: cols,
    crossAxisSpacing: Gap.md,
    mainAxisSpacing: Gap.md,
    mainAxisExtent: cardW + context.scaled(144),
  );
}

class _ShopCategories extends StatelessWidget {
  const _ShopCategories();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= AppBreakpoints.largePhone ? 8 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding - 4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisExtent: 52 + Gap.lg + 36 * context.textScale.clamp(1.0, 1.6),
            crossAxisSpacing: Gap.xs,
          ),
          itemCount: shopCategories.length,
          itemBuilder: (context, i) {
            final cat = shopCategories[i];
            return CategoryTile(
              icon: cat.icon,
              label: categoryLabel(l, cat.id),
              index: i,
              onTap: () => context.push('/shop/products?cat=${cat.id}'),
            );
          },
        );
      },
    );
  }
}

class _ShopBanner extends StatelessWidget {
  const _ShopBanner();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.6,
      child: PressableScale(
        onTap: () => context.push('/wallet'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: Radii.cardBorder,
            gradient: const LinearGradient(colors: [Color(0xFFF4A261), Color(0xFFE76F51)]),
          ),
          padding: const EdgeInsets.all(Gap.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        context.isBn ? '৳৫০ ছাড় — প্রথম অর্ডারে' : '৳50 off your first order',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: Gap.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'TANGAIL50',
                        style: context.text.labelLarge?.copyWith(color: Colors.white, letterSpacing: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.local_offer_rounded, color: Colors.white, size: 56),
            ],
          ),
        ),
      ),
    );
  }
}

class _MadeInTangail extends StatelessWidget {
  const _MadeInTangail({required this.pad});
  final double pad;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      margin: EdgeInsets.fromLTRB(pad, Gap.xl, pad, 0),
      decoration: BoxDecoration(
        color: p.primarySoft,
        borderRadius: Radii.cardBorder,
        border: Border.all(color: p.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            context.l10n.madeInTangail,
            icon: Icons.verified_rounded,
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.xs, Gap.sm),
            onSeeAll: () => context.push('/shop/products?mit=1'),
          ),
          ProductCarousel(
            heroScope: 'shop-mit',
            padding: const EdgeInsets.fromLTRB(Gap.md, 2, Gap.md, Gap.md),
            products: products.where((x) => x.madeInTangail && x.verified).toList(),
          ),
        ],
      ),
    );
  }
}

class _StoreChip extends StatelessWidget {
  const _StoreChip({required this.store});
  final Store store;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: AppCard(
        padding: const EdgeInsets.all(Gap.md),
        onTap: () => context.push('/shop/store/${store.id}'),
        child: Column(
          children: [
            AppAvatar(store.logo, size: 52),
            const SizedBox(height: Gap.sm),
            Text(
              store.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.text.labelMedium,
            ),
            const Spacer(),
            RatingLabel(store.rating),
          ],
        ),
      ),
    );
  }
}
