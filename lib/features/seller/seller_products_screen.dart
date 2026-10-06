import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/models.dart';
import '../../widgets/widgets.dart';

/// Seller's product list with stock badge, publish toggle, edit and delete.
class SellerProductsScreen extends ConsumerWidget {
  const SellerProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final items = ref.watch(sellerProductsProvider);
    return AppScaffold(
      title: l.myProducts,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/seller/products/edit'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.addProduct),
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.inventory_2_outlined,
              title: l.nothingHere,
              actionLabel: l.addProduct,
              onAction: () => context.push('/seller/products/edit'),
            )
          : DemoLoader(
              builder: (_) => ListView.separated(
                padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.md, context.pagePadding, 100),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
                itemBuilder: (_, i) => _SellerProductTile(product: items[i]),
              ),
            ),
    );
  }
}

class _SellerProductTile extends ConsumerWidget {
  const _SellerProductTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final published = !ref.watch(unpublishedProductsProvider).contains(product.id);
    final (stockLabel, tone) = product.stock == 0
        ? (l.outOfStock, StatusTone.danger)
        : product.stock <= 5
        ? (l.lowStock(context.digits(product.stock)), StatusTone.warning)
        : ('${l.stock}: ${context.digits(product.stock)}', StatusTone.success);
    return AppCard(
      padding: const EdgeInsets.all(Gap.md),
      onTap: () => context.push('/seller/products/edit?id=${product.id}'),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: published ? 1 : 0.5,
                child: SizedBox.square(dimension: 72, child: AppImage(product.images.first, radius: 10)),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                    const SizedBox(height: 4),
                    PriceText(product.price, oldPrice: product.oldPrice, size: PriceSize.small),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: Gap.xs,
                      runSpacing: Gap.xs,
                      children: [
                        StatusChip(stockLabel, tone: tone),
                        StatusChip(
                          published ? l.published : l.draft,
                          tone: published ? StatusTone.primary : StatusTone.neutral,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: Gap.lg),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: published,
                      onChanged: (_) => ref.read(unpublishedProductsProvider.notifier).toggle(product.id),
                    ),
                    const SizedBox(width: Gap.xs),
                    Flexible(
                      child: Text(
                        l.publish,
                        style: context.text.labelMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l.edit,
                onPressed: () => context.push('/seller/products/edit?id=${product.id}'),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: l.delete,
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      icon: Icon(Icons.delete_outline_rounded, color: p.emergency),
                      title: Text(l.deleteProductQ),
                      content: Text(product.name),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: p.emergency),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l.delete),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    ref.read(sellerProductsProvider.notifier).remove(product.id);
                    context.toast(
                      l.productDeleted,
                      actionLabel: l.undo,
                      onAction: () => ref.read(sellerProductsProvider.notifier).upsert(product),
                    );
                  }
                },
                icon: Icon(Icons.delete_outline_rounded, color: p.emergency),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
