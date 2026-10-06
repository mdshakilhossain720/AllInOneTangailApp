import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/shop_data.dart';
import '../../data/models.dart';
import '../../widgets/widgets.dart';
import 'seller_dashboard_screen.dart';

/// Orders management: tabs by status, change status bottom sheet.
class SellerOrdersScreen extends ConsumerWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final orders = ref.watch(sellerOrdersProvider);
    final tabs = <(String, bool Function(Order))>[
      (l.all, (_) => true),
      (l.pending, (o) => o.status == OrderStatus.toPay),
      (l.processing, (o) => o.status == OrderStatus.toShip),
      (l.shipped, (o) => o.status == OrderStatus.toReceive),
      (l.delivered, (o) => o.status == OrderStatus.completed),
      (l.cancelled, (o) => o.status == OrderStatus.cancelled || o.status == OrderStatus.returned),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: AppScaffold(
        title: l.manageOrders,
        bottom: TabBar(
          isScrollable: true,
          tabs: [for (final (label, test) in tabs) Tab(text: '$label (${context.digits(orders.where(test).length)})')],
        ),
        body: TabBarView(
          children: [
            for (final (_, test) in tabs)
              Builder(
                builder: (context) {
                  final list = orders.where(test).toList();
                  if (list.isEmpty) return EmptyState(icon: Icons.inbox_outlined, title: l.nothingHere);
                  return ListView.separated(
                    padding: EdgeInsets.all(context.pagePadding),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
                    itemBuilder: (_, i) => SellerOrderCard(order: list[i]),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class SellerOrderCard extends ConsumerWidget {
  const SellerOrderCard({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final first = productById(order.lines.first.productId);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: p.primarySoft,
                child: Text(order.buyer[0], style: TextStyle(color: p.primary)),
              ),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.buyer, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      '${context.digits(order.id)} · ${order.address}',
                      style: context.text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusChip(sellerStatusLabel(context, order.status), tone: sellerStatusTone(order.status)),
            ],
          ),
          const Divider(height: Gap.xl),
          Row(
            children: [
              SizedBox.square(dimension: 52, child: AppImage(first.images.first, radius: 8)),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(first.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodyMedium),
                    Text(
                      '${l.itemsCount(context.digits(order.lines.fold<int>(0, (s, x) => s + x.qty)))} · ${order.payment}',
                      style: context.text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(context.taka(order.total), style: context.text.titleSmall),
            ],
          ),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => confirmCall(context, name: order.buyer, number: '01700-000123'),
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: Text(l.call, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _changeStatus(context, ref),
                  icon: const Icon(Icons.sync_alt_rounded, size: 18),
                  label: Text(l.changeStatus, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final options = [
      OrderStatus.toPay,
      OrderStatus.toShip,
      OrderStatus.toReceive,
      OrderStatus.completed,
      OrderStatus.cancelled,
    ];
    final icons = [
      Icons.hourglass_top_rounded,
      Icons.inventory_2_rounded,
      Icons.local_shipping_rounded,
      Icons.check_circle_rounded,
      Icons.cancel_rounded,
    ];
    final picked = await showAppSheet<OrderStatus>(
      context,
      builder: (ctx) => RadioGroup<OrderStatus>(
        groupValue: order.status,
        onChanged: (v) => Navigator.pop(ctx, v),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l.changeStatus, subtitle: order.id),
            for (final (i, s) in options.indexed)
              RadioListTile<OrderStatus>(
                value: s,
                contentPadding: EdgeInsets.zero,
                secondary: Icon(icons[i]),
                title: Text(sellerStatusLabel(ctx, s)),
              ),
          ],
        ),
      ),
    );
    if (picked != null && picked != order.status && context.mounted) {
      ref.read(sellerOrdersProvider.notifier).setStatus(order.id, picked);
      context.toast(l.statusUpdated(sellerStatusLabel(context, picked)));
    }
  }
}
