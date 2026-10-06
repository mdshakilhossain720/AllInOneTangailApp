import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/shop_data.dart';
import '../../data/models.dart';
import '../../widgets/widgets.dart';
import '../shop/orders_screen.dart';
import 'seller_orders_screen.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final orders = ref.watch(sellerOrdersProvider);
    final myProducts = ref.watch(sellerProductsProvider);
    final store = storeById('s1');
    final pending = orders.where((o) => o.status == OrderStatus.toShip || o.status == OrderStatus.toPay).length;
    final days = [for (var i = 6; i >= 0; i--) DateTime.now().subtract(Duration(days: i))];

    final stats = [
      (l.todaySales, context.taka(weeklySales.last), Icons.payments_rounded, '+12%', 0),
      (
        l.orders,
        context.digits(orders.length),
        Icons.receipt_long_rounded,
        context.digits('$pending ${l.pending.toLowerCase()}'),
        3,
      ),
      (
        l.myProducts,
        context.digits(myProducts.length),
        Icons.inventory_2_rounded,
        '${context.digits(ref.watch(unpublishedProductsProvider).length)} ${l.draft.toLowerCase()}',
        4,
      ),
      (
        l.rating,
        context.digits(store.rating.toStringAsFixed(1)),
        Icons.star_rounded,
        l.followers(context.compact(store.followers)),
        5,
      ),
    ];

    return AppScaffold(
      title: l.sellerCenter,
      actions: [
        IconButton(
          tooltip: l.storeSettings,
          onPressed: () => context.push('/seller/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/seller/products/edit'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.addProduct),
      ),
      body: AppRefresh(
        child: ListView(
          padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.md, context.pagePadding, 100),
          children: [
            // Store header.
            AppCard(
              onTap: () => context.push('/shop/store/${store.id}'),
              child: Row(
                children: [
                  AppAvatar(store.logo, size: 52),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.name, style: context.text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(l.visitStore, style: context.text.bodySmall?.copyWith(color: p.primary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
            const SizedBox(height: Gap.md),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 720 ? 4 : 2;
                final w = (c.maxWidth - (cols - 1) * Gap.md) / cols;
                return Wrap(
                  spacing: Gap.md,
                  runSpacing: Gap.md,
                  children: [
                    for (final (label, value, icon, sub, color) in stats)
                      SizedBox(
                        width: w,
                        child: AppCard(
                          padding: const EdgeInsets.all(Gap.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PastelIcon(icon, index: color, size: 36),
                              const SizedBox(height: Gap.sm),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(value, style: context.text.headlineSmall),
                              ),
                              Text(label, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(
                                sub,
                                style: context.text.labelSmall?.copyWith(color: p.success),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: Gap.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(l.salesThisWeek, style: context.text.titleMedium)),
                      Text(
                        context.taka(weeklySales.fold(0.0, (a, b) => a + b)),
                        style: context.text.titleSmall?.copyWith(color: p.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.lg),
                  SimpleBarChart(
                    values: weeklySales,
                    labels: [
                      for (final d in days)
                        DateFormat('E', context.isBn ? 'bn' : 'en').format(d).substring(0, context.isBn ? null : 2),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.md),
            LayoutBuilder(
              builder: (context, c) {
                final links = [
                  (Icons.inventory_2_outlined, l.myProducts, '/seller/products'),
                  (Icons.receipt_long_outlined, l.manageOrders, '/seller/orders'),
                  (Icons.account_balance_wallet_outlined, l.payouts, '/seller/settings?tab=1'),
                  (Icons.storefront_outlined, l.storeSettings, '/seller/settings'),
                ];
                final cols = c.maxWidth >= 600 ? 4 : 2;
                final w = (c.maxWidth - (cols - 1) * Gap.md) / cols;
                return Wrap(
                  spacing: Gap.md,
                  runSpacing: Gap.md,
                  children: [
                    for (final (i, (icon, label, route)) in links.indexed)
                      SizedBox(
                        width: w,
                        child: AppCard(
                          padding: const EdgeInsets.all(Gap.md),
                          onTap: () => context.push(route),
                          child: Row(
                            children: [
                              PastelIcon(icon, index: i + 1, size: 36),
                              const SizedBox(width: Gap.sm),
                              Expanded(
                                child: Text(
                                  label,
                                  style: context.text.titleSmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            SectionHeader(
              l.recentOrders,
              padding: const EdgeInsets.only(top: Gap.xl, bottom: Gap.sm),
              onSeeAll: () => context.push('/seller/orders'),
            ),
            for (final o in orders.take(3)) ...[SellerOrderCard(order: o), const SizedBox(height: Gap.md)],
          ],
        ),
      ),
    );
  }
}

String sellerStatusLabel(BuildContext context, OrderStatus s) {
  final l = context.l10n;
  return switch (s) {
    OrderStatus.toPay => l.pending,
    OrderStatus.toShip => l.processing,
    OrderStatus.toReceive => l.shipped,
    OrderStatus.completed => l.delivered,
    OrderStatus.cancelled => l.cancelled,
    OrderStatus.returned => l.returns,
  };
}

/// Re-export for convenience in seller screens.
StatusTone sellerStatusTone(OrderStatus s) => orderStatusTone(s);
