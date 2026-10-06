import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/shop_data.dart';
import '../../data/models.dart';
import '../../widgets/widgets.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _voucher = TextEditingController();
  String? _voucherError;

  @override
  void dispose() {
    _voucher.dispose();
    super.dispose();
  }

  void _applyVoucher() {
    final l = context.l10n;
    if (_voucher.text.trim().toUpperCase() == 'TANGAIL50') {
      ref.read(appliedVoucherProvider.notifier).set(50);
      setState(() => _voucherError = null);
      FocusScope.of(context).unfocus();
      context.toast(l.voucherApplied);
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _voucherError = l.voucherInvalid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final cart = ref.watch(cartProvider);
    final totals = ref.watch(cartTotalsProvider);
    final voucher = ref.watch(appliedVoucherProvider);
    final allSelected = cart.isNotEmpty && cart.every((e) => e.selected);

    // Group items by store, preserving order.
    final groups = <String, List<CartItem>>{};
    for (final item in cart) {
      groups.putIfAbsent(productById(item.productId).storeId, () => []).add(item);
    }

    if (cart.isEmpty) {
      return AppScaffold(
        title: l.myCart,
        body: EmptyState(
          icon: Icons.shopping_cart_outlined,
          color: AppColors.secondary,
          title: l.emptyCart,
          message: l.emptyCartHint,
          actionLabel: l.startShopping,
          onAction: () => context.go('/shop'),
        ),
      );
    }

    final total = (totals.subtotal - (totals.count > 0 ? voucher : 0)).clamp(0, 1 << 31);

    return AppScaffold(
      title: '${l.myCart} (${context.digits(cart.length)})',
      actions: [
        IconButton(
          tooltip: l.delete,
          onPressed: totals.count == 0
              ? null
              : () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l.delete),
                      content: Text(l.itemsCount(context.digits(cart.where((e) => e.selected).length))),
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
                  if (ok == true) ref.read(cartProvider.notifier).removeSelected();
                },
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
      bottomBar: Row(
        children: [
          Checkbox(
            value: allSelected,
            onChanged: (v) => ref.read(cartProvider.notifier).selectAll(v ?? false),
            semanticLabel: l.selectAll,
          ),
          Flexible(child: Text(l.all, style: context.text.labelLarge)),
          const SizedBox(width: Gap.sm),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.total, style: context.text.bodySmall),
                PriceText(total, size: PriceSize.medium),
              ],
            ),
          ),
          const SizedBox(width: Gap.md),
          Flexible(
            flex: 4,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: const Color(0xFF3B2410),
                padding: const EdgeInsets.symmetric(horizontal: Gap.md),
              ),
              onPressed: totals.count == 0 ? null : () => context.push('/checkout'),
              child: Text(l.checkoutCount(context.digits(totals.count)), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          for (final entry in groups.entries) ...[
            _StoreGroup(storeId: entry.key, items: entry.value),
            const SizedBox(height: Gap.md),
          ],
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _voucher,
                        textCapitalization: TextCapitalization.characters,
                        onSubmitted: (_) => _applyVoucher(),
                        decoration: InputDecoration(
                          labelText: l.voucherCode,
                          hintText: l.voucherHint,
                          errorText: _voucherError,
                          prefixIcon: const Icon(Icons.confirmation_number_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: Gap.sm),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: FilledButton.tonal(onPressed: _applyVoucher, child: Text(l.apply)),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.md),
                KeyValueRow(l.subtotal, context.taka(totals.subtotal + totals.savings)),
                if (totals.savings > 0)
                  KeyValueRow(l.discount, '- ${context.taka(totals.savings)}', valueColor: p.success),
                if (voucher > 0 && totals.count > 0)
                  KeyValueRow(l.voucher, '- ${context.taka(voucher)}', valueColor: p.success),
                const Divider(height: Gap.xl),
                KeyValueRow(l.total, context.taka(total), bold: true),
              ],
            ),
          ),
          const SizedBox(height: Gap.xl),
        ],
      ),
    );
  }
}

class _StoreGroup extends ConsumerWidget {
  const _StoreGroup({required this.storeId, required this.items});
  final String storeId;
  final List<CartItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = storeById(storeId);
    final all = items.every((e) => e.selected);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(Gap.xs, Gap.xs, Gap.md, Gap.sm),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: all,
                onChanged: (v) => ref.read(cartProvider.notifier).selectStore(storeId, v ?? false),
                semanticLabel: store.name,
              ),
              const Icon(Icons.storefront_rounded, size: 18),
              const SizedBox(width: Gap.xs),
              Flexible(
                child: InkWell(
                  onTap: () => context.push('/shop/store/$storeId'),
                  child: Text(store.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
              if (store.verified) ...[const SizedBox(width: 4), const VerifiedBadge(compact: true)],
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
          for (final item in items) _CartRow(item: item),
        ],
      ),
    );
  }
}

class _CartRow extends ConsumerWidget {
  const _CartRow({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final pr = productById(item.productId);
    final notifier = ref.read(cartProvider.notifier);
    return Dismissible(
      key: ValueKey(item.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: Gap.xl),
        decoration: BoxDecoration(color: p.emergency, borderRadius: Radii.buttonBorder),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        final index = ref.read(cartProvider).indexWhere((e) => e.key == item.key);
        final removed = notifier.remove(item.key);
        context.toast(
          l.itemRemoved,
          actionLabel: l.undo,
          onAction: () {
            if (removed != null) notifier.restore(removed, index);
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: item.selected, onChanged: (_) => notifier.toggle(item.key), semanticLabel: pr.name),
            GestureDetector(
              onTap: () => context.push('/shop/product/${pr.id}'),
              child: SizedBox.square(dimension: 76, child: AppImage(pr.images.first, radius: 10)),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pr.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.bodyMedium),
                  if (item.size != null || item.color != null) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: Gap.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (item.size != null) Pill(item.size!, color: p.muted, dense: true),
                        if (item.color != null)
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: p.border),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: Gap.xs),
                  Row(
                    children: [
                      Expanded(
                        child: PriceText(pr.price, oldPrice: pr.oldPrice, size: PriceSize.small),
                      ),
                      QuantityStepper(
                        dense: true,
                        value: item.qty,
                        max: pr.stock.clamp(1, 99),
                        onChanged: (v) => notifier.setQty(item.key, v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
