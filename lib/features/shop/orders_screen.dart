import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/shop_data.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';

String orderStatusLabel(AppLocalizations l, OrderStatus s) => switch (s) {
  OrderStatus.toPay => l.toPay,
  OrderStatus.toShip => l.toShip,
  OrderStatus.toReceive => l.toReceive,
  OrderStatus.completed => l.completed,
  OrderStatus.returned => l.returns,
  OrderStatus.cancelled => l.cancelled,
};

StatusTone orderStatusTone(OrderStatus s) => switch (s) {
  OrderStatus.toPay => StatusTone.warning,
  OrderStatus.toShip => StatusTone.info,
  OrderStatus.toReceive => StatusTone.primary,
  OrderStatus.completed => StatusTone.success,
  OrderStatus.returned => StatusTone.neutral,
  OrderStatus.cancelled => StatusTone.danger,
};

/// My Orders with status tabs.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final orders = ref.watch(ordersProvider);
    final tabs = <(String, bool Function(Order))>[
      (l.all, (_) => true),
      (l.toPay, (o) => o.status == OrderStatus.toPay),
      (l.toShip, (o) => o.status == OrderStatus.toShip),
      (l.toReceive, (o) => o.status == OrderStatus.toReceive),
      (l.completed, (o) => o.status == OrderStatus.completed),
      (l.returns, (o) => o.status == OrderStatus.returned || o.status == OrderStatus.cancelled),
    ];
    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialTab.clamp(0, tabs.length - 1),
      child: AppScaffold(
        title: l.myOrders,
        bottom: TabBar(
          isScrollable: true,
          tabs: [
            for (final (label, test) in tabs)
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label),
                    if (orders.where(test).isNotEmpty && label != l.all) ...[
                      const SizedBox(width: 4),
                      CountBadge(count: orders.where(test).length, child: const SizedBox(width: 12, height: 12)),
                    ],
                  ],
                ),
              ),
          ],
        ),
        body: TabBarView(
          children: [
            for (final (_, test) in tabs)
              Builder(
                builder: (context) {
                  final list = orders.where(test).toList();
                  if (list.isEmpty) {
                    return EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: l.nothingHere,
                      actionLabel: l.startShopping,
                      onAction: () => context.go('/shop'),
                    );
                  }
                  return DemoLoader(
                    builder: (_) => ListView.separated(
                      padding: EdgeInsets.all(context.pagePadding),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
                      itemBuilder: (_, i) => OrderCard(order: list[i]),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends ConsumerWidget {
  const OrderCard({super.key, required this.order, this.onTap});
  final Order order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final first = productById(order.lines.first.productId);
    final store = storeById(first.storeId);
    final more = order.lines.length - 1;
    return AppCard(
      onTap: onTap ?? () => context.push('/orders/${order.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 18),
              const SizedBox(width: Gap.xs),
              Expanded(
                child: Text(store.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              StatusChip(orderStatusLabel(l, order.status), tone: orderStatusTone(order.status)),
            ],
          ),
          const Divider(height: Gap.xl),
          Row(
            children: [
              SizedBox.square(dimension: 64, child: AppImage(first.images.first, radius: 10)),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(first.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.bodyMedium),
                    if (more > 0) Text('+ ${l.itemsCount(context.digits(more))}', style: context.text.bodySmall),
                    Text(
                      '${context.digits(order.id)} · ${context.shortDate(order.placedAt)}',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              Expanded(child: Text('${l.total}: ${context.taka(order.total)}', style: context.text.titleSmall)),
              const SizedBox(width: Gap.sm),
              Flexible(child: _actions(context, ref, order)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, WidgetRef ref, Order o) {
    final l = context.l10n;
    final notifier = ref.read(ordersProvider.notifier);
    return switch (o.status) {
      OrderStatus.toPay => FilledButton(
        onPressed: () {
          notifier.setStatus(o.id, OrderStatus.toShip);
          context.toast(l.statusUpdated(l.toShip));
        },
        child: Text(l.payNow, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      OrderStatus.toReceive => FilledButton(
        onPressed: () {
          notifier.setStatus(o.id, OrderStatus.completed);
          context.toast(l.statusUpdated(l.completed));
        },
        child: Text(l.confirmReceived, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      OrderStatus.completed => OutlinedButton(
        onPressed: () => context.push('/orders/${o.id}/review'),
        child: Text(l.writeReview, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      _ => TextButton(
        onPressed: () => context.push('/orders/${o.id}'),
        child: Text(l.viewDetails, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    };
  }
}

/// Order detail with vertical tracking timeline and cancel / return / review.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final order = ref.watch(ordersProvider).where((o) => o.id == orderId).firstOrNull;
    if (order == null) {
      return AppScaffold(
        title: l.orderDetail,
        body: EmptyState(icon: Icons.receipt_long_outlined, title: l.nothingHere),
      );
    }

    final placed = order.placedAt;
    final stage = switch (order.status) {
      OrderStatus.toPay => 0,
      OrderStatus.toShip => 1,
      OrderStatus.toReceive => 3,
      OrderStatus.completed || OrderStatus.returned => 4,
      OrderStatus.cancelled => -1,
    };
    final steps = [
      (l.orderPlaced, 'Order ${order.id}', placed),
      (
        l.processing,
        context.isBn ? 'বিক্রেতা প্যাক করছেন' : 'Seller is packing your items',
        placed.add(const Duration(hours: 3)),
      ),
      (
        l.shipped,
        context.isBn ? 'টাঙ্গাইল হাবে হস্তান্তর' : 'Handed to Tangail hub courier',
        placed.add(const Duration(hours: 20)),
      ),
      (
        context.isBn ? 'ডেলিভারির পথে' : 'Out for delivery',
        context.isBn ? 'রাইডার: সোহেল (০১৭০০-০০০০৯৯)' : 'Rider: Sohel (01700-000099)',
        placed.add(const Duration(days: 1, hours: 4)),
      ),
      (
        l.delivered,
        context.isBn ? 'গ্রহণ করেছেন' : 'Received by customer',
        placed.add(const Duration(days: 1, hours: 9)),
      ),
    ];

    return AppScaffold(
      title: l.orderDetail,
      bottomBar: order.status == OrderStatus.toShip || order.status == OrderStatus.toPay
          ? PrimaryButton(
              label: l.cancelOrder,
              outlined: true,
              color: p.emergency,
              onPressed: () => _cancel(context, ref, order),
            )
          : order.status == OrderStatus.completed
          ? Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: () => _return(context, ref, order), child: Text(l.returnRequest)),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.push('/orders/${order.id}/review'),
                    child: Text(l.writeReview),
                  ),
                ),
              ],
            )
          : null,
      body: ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          AppCard(
            color: p.isDark ? null : p.primarySoft,
            child: Row(
              children: [
                Icon(
                  order.status == OrderStatus.cancelled ? Icons.cancel_rounded : Icons.local_shipping_rounded,
                  color: order.status == OrderStatus.cancelled ? p.emergency : p.primary,
                  size: 36,
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusChip(orderStatusLabel(l, order.status), tone: orderStatusTone(order.status)),
                      const SizedBox(height: 4),
                      Text('${l.orderId}: ${context.digits(order.id)}', style: context.text.titleSmall),
                      Text(context.shortDate(order.placedAt), style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.md),
          if (stage >= 0)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.trackOrder, style: context.text.titleMedium),
                  const SizedBox(height: Gap.lg),
                  for (var i = 0; i < steps.length; i++)
                    TimelineTile(
                      title: steps[i].$1,
                      subtitle: steps[i].$2,
                      time: i <= stage ? '${context.shortDate(steps[i].$3)} · ${context.clock(steps[i].$3)}' : null,
                      state: i < stage
                          ? TimelineState.done
                          : (i == stage ? TimelineState.current : TimelineState.upcoming),
                      isFirst: i == 0,
                      isLast: i == steps.length - 1,
                      icon: i == stage ? Icons.local_shipping_rounded : null,
                    ),
                ],
              ),
            ),
          const SizedBox(height: Gap.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.stepAddress, style: context.text.titleMedium),
                const SizedBox(height: Gap.xs),
                Text(order.buyer, style: context.text.titleSmall),
                Text(order.address, style: context.text.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: Gap.md),
          AppCard(
            child: Column(
              children: [
                for (final line in order.lines)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => context.push('/shop/product/${line.productId}'),
                    leading: SizedBox.square(
                      dimension: 52,
                      child: AppImage(productById(line.productId).images.first, radius: 8),
                    ),
                    title: Text(productById(line.productId).name, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(context.digits('×${line.qty}')),
                    trailing: Text(context.taka(line.price * line.qty), style: context.text.titleSmall),
                  ),
                const Divider(),
                KeyValueRow(l.subtotal, context.taka(order.subtotal)),
                KeyValueRow(l.deliveryFee, context.taka(order.deliveryFee)),
                KeyValueRow(l.stepPayment, order.payment),
                const Divider(height: Gap.xl),
                KeyValueRow(l.total, context.taka(order.total), bold: true),
              ],
            ),
          ),
          const SizedBox(height: Gap.md),
          OutlinedButton.icon(
            onPressed: () => context.push('/shop/chat/${productById(order.lines.first.productId).storeId}'),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: Text(l.chat),
          ),
        ],
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, Order order) async {
    final l = context.l10n;
    final reasons = context.isBn
        ? [
            'ভুল পণ্য অর্ডার করেছি',
            'ঠিকানা পরিবর্তন করতে চাই',
            'অন্য জায়গায় কম দামে পেয়েছি',
            'ডেলিভারি সময় বেশি',
            'অন্যান্য',
          ]
        : ['Ordered by mistake', 'Need to change address', 'Found a better price', 'Delivery takes too long', 'Other'];
    var selected = reasons.first;
    final ok = await showAppSheet<bool>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l.cancelReason),
            RadioGroup<String>(
              groupValue: selected,
              onChanged: (v) => setS(() => selected = v!),
              child: Column(
                children: [
                  for (final r in reasons)
                    RadioListTile<String>(value: r, title: Text(r), contentPadding: EdgeInsets.zero),
                ],
              ),
            ),
            const SizedBox(height: Gap.md),
            PrimaryButton(
              label: l.cancelOrder,
              color: ctx.palette.emergency,
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );
    if (ok == true && context.mounted) {
      ref.read(ordersProvider.notifier).setStatus(order.id, OrderStatus.cancelled);
      context.toast(l.orderCancelled);
    }
  }

  Future<void> _return(BuildContext context, WidgetRef ref, Order order) async {
    final l = context.l10n;
    final ok = await showAppSheet<bool>(
      context,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetTitle(l.returnRequest),
          AppTextField(label: l.whatsWrong, maxLines: 3),
          const PhotoPickerGrid(max: 3),
          const SizedBox(height: Gap.lg),
          PrimaryButton(label: l.submit, onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ref.read(ordersProvider.notifier).setStatus(order.id, OrderStatus.returned);
      context.toast(l.returnSubmitted);
    }
  }
}

/// Rate each product, add text and photos.
class WriteReviewScreen extends ConsumerStatefulWidget {
  const WriteReviewScreen({super.key, required this.orderId});
  final String orderId;

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final Map<String, int> _stars = {};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final order = ref.watch(ordersProvider).where((o) => o.id == widget.orderId).firstOrNull ?? demoOrders.first;
    return AppScaffold(
      title: l.writeReview,
      bottomBar: PrimaryButton(
        label: l.submit,
        onPressed: () {
          context.toast(l.reviewSubmitted);
          context.pop();
        },
      ),
      body: ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          for (final line in order.lines) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox.square(
                        dimension: 56,
                        child: AppImage(productById(line.productId).images.first, radius: 8),
                      ),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: Text(
                          productById(line.productId).name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.md),
                  Center(
                    child: Wrap(
                      children: [
                        for (var i = 1; i <= 5; i++)
                          IconButton(
                            tooltip: '$i',
                            onPressed: () => setState(() => _stars[line.productId] = i),
                            icon: AnimatedScale(
                              scale: (_stars[line.productId] ?? 5) >= i ? 1.15 : 1,
                              duration: Motion.fast,
                              child: Icon(
                                (_stars[line.productId] ?? 5) >= i ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: const Color(0xFFF5B301),
                                size: 34,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Gap.sm),
                  AppTextField(hint: context.isBn ? 'পণ্যটি কেমন লেগেছে?' : 'How was the product?', maxLines: 3),
                  PhotoPickerGrid(max: 3, seed: 'rev${line.productId}'),
                ],
              ),
            ),
            const SizedBox(height: Gap.md),
          ],
        ],
      ),
    );
  }
}
