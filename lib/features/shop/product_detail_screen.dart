import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/common_data.dart';
import '../../data/demo/shop_data.dart';
import '../../data/models.dart';
import '../../widgets/widgets.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId, this.heroScope, this.embedded = false});

  final String productId;
  final String? heroScope;

  /// True when shown in the right pane of a tablet master-detail layout.
  final bool embedded;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final _addKey = GlobalKey();
  late final Product product = resolveProduct(ref, widget.productId);
  late String? _size = product.sizes.isEmpty ? null : product.sizes[product.sizes.length > 1 ? 1 : 0];
  late Color? _color = product.colors.isEmpty ? null : product.colors.first;
  int _qty = 1;
  late String _deliverTo = upazilaById(ref.read(upazilaProvider)).name.en;
  bool _pickup = false;

  /// Lets the extracted info column update this screen's selection state.
  void update(VoidCallback fn) => setState(fn);

  void _addToCart() {
    HapticFeedback.mediumImpact();
    FlyToCart.run(
      context,
      fromKey: _addKey,
      image: product.images.first,
      onArrive: () {
        ref.read(cartProvider.notifier).add(product.id, qty: _qty, size: _size, color: _color);
        if (mounted) {
          context.toast(
            context.l10n.addedToCart,
            actionLabel: context.l10n.viewCart,
            onAction: () => context.push('/cart'),
          );
        }
      },
    );
  }

  void _buyNow() {
    final cart = ref.read(cartProvider.notifier);
    cart.selectAll(false);
    cart.add(product.id, qty: _qty, size: _size, color: _color);
    final key = CartItem(productId: product.id, qty: _qty, size: _size, color: _color).key;
    if (!ref.read(cartProvider).firstWhere((e) => e.key == key).selected) cart.toggle(key);
    context.push('/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pr = product;
    final store = storeById(pr.storeId);
    final heroTag = productHero(pr.id, widget.heroScope);

    final gallery = ImageGallery(images: pr.images, heroTag: heroTag);

    final info = _InfoColumn(state: this, store: store);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(pr.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
            const DemoBadge(),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.share,
            onPressed: () => context.toast(l.sharedDemo),
            icon: const Icon(Icons.share_outlined),
          ),
          if (!widget.embedded) const CartIconButton(),
          const SizedBox(width: Gap.xs),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, c) {
            // Two columns (sticky gallery + scrolling info) on wide panes.
            if (c.maxWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: c.maxWidth * 0.45,
                    child: Padding(
                      padding: const EdgeInsets.all(Gap.lg),
                      child: ClipRRect(borderRadius: Radii.cardBorder, child: gallery),
                    ),
                  ),
                  Expanded(child: SingleChildScrollView(child: info)),
                ],
              );
            }
            return ListView(
              children: [
                MaxWidth(maxWidth: 640, child: gallery),
                MaxWidth(maxWidth: 840, child: info),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: StickyBar(
        child: Row(
          children: [
            _BarIcon(
              icon: Icons.storefront_outlined,
              label: l.visitStore,
              onTap: () => context.push('/shop/store/${store.id}'),
            ),
            _BarIcon(
              icon: Icons.chat_bubble_outline_rounded,
              label: l.chat,
              onTap: () => context.push('/shop/chat/${store.id}?product=${pr.id}'),
            ),
            const SizedBox(width: Gap.sm),
            Expanded(
              child: OutlinedButton(
                key: _addKey,
                onPressed: pr.stock == 0 ? null : _addToCart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC2611A),
                  side: const BorderSide(color: AppColors.secondary, width: 1.4),
                  padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
                ),
                child: Text(l.addToCart, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(width: Gap.sm),
            Expanded(
              child: FilledButton(
                onPressed: pr.stock == 0 ? null : _buyNow,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: const Color(0xFF3B2410),
                  padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
                ),
                child: Text(
                  pr.stock == 0 ? l.outOfStock : l.buyNow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  const _BarIcon({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon, color: context.palette.text),
    );
  }
}

/// Everything below the gallery.
class _InfoColumn extends ConsumerWidget {
  const _InfoColumn({required this.state, required this.store});

  final _ProductDetailScreenState state;
  final Store store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final pr = state.product;
    final s = state;
    final pad = EdgeInsets.symmetric(horizontal: context.pagePadding);
    final (fee, days) = deliveryFor(s._deliverTo);
    final followed = ref.watch(followedStoresProvider).contains(store.id);
    final similar = products.where((x) => x.categoryId == pr.categoryId && x.id != pr.id).take(8).toList();

    Widget card(Widget child) => Padding(
      padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.md, context.pagePadding, 0),
      child: AppCard(child: child),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- Price block
        Container(
          color: p.surface,
          padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.lg, context.pagePadding, Gap.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: PriceText(pr.price, oldPrice: pr.oldPrice, size: PriceSize.large),
                  ),
                  if (pr.discountPct != null)
                    Pill(l.off(context.digits(pr.discountPct!)), color: p.emergency, solid: true),
                  HeartButton(productId: pr.id, filledBackground: false, size: 24),
                ],
              ),
              const SizedBox(height: Gap.sm),
              Text(pr.name, style: context.text.titleLarge),
              const SizedBox(height: Gap.sm),
              Wrap(
                spacing: Gap.md,
                runSpacing: Gap.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  RatingStars(pr.rating, count: productReviews.length * 31),
                  Text(l.sold(context.compact(pr.sold)), style: context.text.bodySmall),
                  if (pr.verified) const VerifiedBadge(),
                  if (pr.madeInTangail)
                    Pill(l.madeInTangail, color: p.primary, icon: Icons.location_on_rounded, dense: true),
                ],
              ),
            ],
          ),
        ),
        // ---- Variants, quantity, stock
        card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pr.sizes.isNotEmpty) ...[
                Text(l.size, style: context.text.titleSmall),
                const SizedBox(height: Gap.sm),
                Wrap(
                  spacing: Gap.sm,
                  runSpacing: Gap.sm,
                  children: [
                    for (final sz in pr.sizes)
                      ChoiceChip(
                        label: Text(sz),
                        selected: s._size == sz,
                        onSelected: (_) => s.update(() => s._size = sz),
                      ),
                  ],
                ),
                const SizedBox(height: Gap.lg),
              ],
              if (pr.colors.isNotEmpty) ...[
                Text(l.color, style: context.text.titleSmall),
                const SizedBox(height: Gap.sm),
                Wrap(
                  spacing: Gap.sm,
                  children: [
                    for (final c in pr.colors)
                      Semantics(
                        button: true,
                        selected: s._color == c,
                        label: '${l.color} #${c.toARGB32().toRadixString(16).substring(2)}',
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => s.update(() => s._color = c),
                          child: SizedBox.square(
                            dimension: 48,
                            child: Center(
                              child: AnimatedContainer(
                                duration: Motion.fast,
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: s._color == c ? p.primary : p.border,
                                    width: s._color == c ? 3 : 1,
                                  ),
                                ),
                                child: s._color == c
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 18,
                                        color: c.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Gap.lg),
              ],
              Row(
                children: [
                  Flexible(child: Text(l.quantity, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: Gap.md),
                  QuantityStepper(
                    value: s._qty,
                    max: pr.stock.clamp(1, 99),
                    onChanged: (v) => s.update(() => s._qty = v),
                  ),
                  const SizedBox(width: Gap.md),
                  Expanded(child: _StockIndicator(stock: pr.stock)),
                ],
              ),
            ],
          ),
        ),
        // ---- Delivery
        card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: p.primary),
                  const SizedBox(width: Gap.sm),
                  Expanded(child: Text(l.deliverTo(''), style: context.text.titleSmall)),
                ],
              ),
              const SizedBox(height: Gap.sm),
              DropdownButtonFormField<String>(
                initialValue: s._deliverTo,
                isExpanded: true,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined), isDense: true),
                items: [for (final u in upazilas) DropdownMenuItem(value: u.name.en, child: Text(u.name.of(context)))],
                onChanged: (v) => s.update(() => s._deliverTo = v!),
              ),
              const SizedBox(height: Gap.sm),
              KeyValueRow(l.deliveryFee, s._pickup ? context.taka(0) : context.taka(fee)),
              KeyValueRow(l.homeDelivery, l.estDelivery(context.digits(days))),
              if (pr.pickup)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: s._pickup,
                  onChanged: (v) => s.update(() => s._pickup = v!),
                  title: Text(l.pickupAvailable, style: context.text.bodyMedium?.copyWith(color: p.success)),
                  secondary: Icon(Icons.storefront_rounded, color: p.success),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
            ],
          ),
        ),
        // ---- Seller
        card(
          Column(
            children: [
              Row(
                children: [
                  AppAvatar(store.logo, size: 52),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                store.name,
                                style: context.text.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (store.verified) ...[const SizedBox(width: 4), const VerifiedBadge(compact: true)],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: Gap.sm,
                          children: [
                            RatingLabel(store.rating),
                            Text(
                              l.followers(context.compact(store.followers + (followed ? 1 : 0))),
                              style: context.text.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: TextButton(
                      onPressed: () => ref.read(followedStoresProvider.notifier).toggle(store.id),
                      child: Text(followed ? l.following : l.follow, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/shop/store/${store.id}'),
                      icon: const Icon(Icons.storefront_outlined, size: 18),
                      label: Text(l.visitStore, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/shop/chat/${store.id}?product=${pr.id}'),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                      label: Text(l.chat, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // ---- Description & specs
        card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.description, style: context.text.titleMedium),
              const SizedBox(height: Gap.sm),
              ReadMoreText(pr.description),
              const SizedBox(height: Gap.md),
              Text(l.specifications, style: context.text.titleMedium),
              const SizedBox(height: Gap.sm),
              ClipRRect(
                borderRadius: Radii.buttonBorder,
                child: Table(
                  columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
                  border: TableBorder.symmetric(inside: BorderSide(color: p.border)),
                  children: [
                    for (final (i, e) in pr.specs.entries.indexed)
                      TableRow(
                        decoration: BoxDecoration(color: i.isEven ? p.surfaceAlt : p.surface),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(Gap.sm),
                            child: Text(e.key, style: context.text.bodySmall),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(Gap.sm),
                            child: Text(e.value, style: context.text.bodyMedium),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ---- Reviews
        card(_ReviewsBlock(rating: pr.rating)),
        // ---- Q&A
        card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(l.questions, style: context.text.titleMedium)),
                  Flexible(
                    child: TextButton(
                      onPressed: () => _askQuestion(context),
                      child: Text(l.askQuestion, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
              for (final (q, a) in productQna) ...[
                const SizedBox(height: Gap.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Pill('Q', color: p.info, solid: true, dense: true),
                    const SizedBox(width: Gap.sm),
                    Expanded(child: Text(q, style: context.text.titleSmall)),
                  ],
                ),
                const SizedBox(height: Gap.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Pill('A', color: p.success, solid: true, dense: true),
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: Text(a, style: context.text.bodyMedium?.copyWith(color: p.muted)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SectionHeader(
          l.similarProducts,
          padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.xl, context.pagePadding, Gap.sm),
        ),
        ProductCarousel(
          heroScope: 'similar-${pr.id}',
          products: similar,
          padding: pad.add(const EdgeInsets.symmetric(vertical: 2)),
        ),
        const SizedBox(height: Gap.xl),
      ],
    );
  }

  void _askQuestion(BuildContext context) {
    final l = context.l10n;
    showAppSheet<void>(
      context,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetTitle(l.askQuestion),
          AppTextField(hint: l.askQuestion, maxLines: 3),
          PrimaryButton(
            label: l.submit,
            onPressed: () {
              Navigator.pop(ctx);
              context.toast(l.questionPosted);
            },
          ),
        ],
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  const _StockIndicator({required this.stock});
  final int stock;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = context.l10n;
    final (text, color, value) = stock == 0
        ? (l.outOfStock, p.emergency, 0.0)
        : stock <= 5
        ? (l.lowStock(context.digits(stock)), const Color(0xFFD9772B), stock / 25)
        : (l.inStock(context.digits(stock)), p.success, (stock / 50).clamp(0.2, 1.0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: context.text.labelMedium?.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 5,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}

class _ReviewsBlock extends StatelessWidget {
  const _ReviewsBlock({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    const breakdown = [0.72, 0.18, 0.06, 0.03, 0.01];
    final photos = productReviews.expand((r) => r.images).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.ratingsReviews, style: context.text.titleMedium),
        const SizedBox(height: Gap.md),
        Row(
          children: [
            Column(
              children: [
                Text(context.digits(rating.toStringAsFixed(1)), style: context.text.displaySmall),
                RatingStars(rating, showValue: false),
                const SizedBox(height: 2),
                Text(context.digits('${productReviews.length * 31}'), style: context.text.bodySmall),
              ],
            ),
            const SizedBox(width: Gap.xl),
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < 5; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(width: 14, child: Text(context.digits(5 - i), style: context.text.labelSmall)),
                          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF5B301)),
                          const SizedBox(width: Gap.xs),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: breakdown[i]),
                                duration: Motion.slow,
                                builder: (_, v, _) => LinearProgressIndicator(
                                  value: v,
                                  minHeight: 7,
                                  color: const Color(0xFFF5B301),
                                  backgroundColor: p.surfaceAlt,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              context.digits('${(breakdown[i] * 100).round()}%'),
                              textAlign: TextAlign.end,
                              style: context.text.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (photos.isNotEmpty) ...[
          const SizedBox(height: Gap.lg),
          Text(l.photoReviews, style: context.text.titleSmall),
          const SizedBox(height: Gap.sm),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: Gap.sm),
              itemBuilder: (_, i) => SizedBox.square(dimension: 72, child: AppImage(photos[i], radius: 10)),
            ),
          ),
        ],
        const SizedBox(height: Gap.md),
        for (final r in productReviews) ReviewTile(review: r),
      ],
    );
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: p.primarySoft,
                child: Text(review.name[0], style: context.text.labelLarge?.copyWith(color: p.primary)),
              ),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    RatingStars(review.rating, size: 12, showValue: false),
                  ],
                ),
              ),
              Text(context.l10n.daysShort(context.digits(review.daysAgo)), style: context.text.bodySmall),
            ],
          ),
          const SizedBox(height: Gap.sm),
          Text(review.text, style: context.text.bodyMedium),
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: Gap.sm),
            Wrap(
              spacing: Gap.sm,
              children: [
                for (final img in review.images) SizedBox.square(dimension: 64, child: AppImage(img, radius: 8)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
