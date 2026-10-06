import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/common_data.dart';
import '../../data/demo/shop_data.dart';
import '../../widgets/widgets.dart';
import 'shop_home_screen.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key, required this.storeId});
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final store = storeById(storeId);
    final followed = ref.watch(followedStoresProvider).contains(store.id);
    final items = products.where((x) => x.storeId == store.id).toList();
    final coverH = (context.screenWidth * 0.42).clamp(150.0, 260.0);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: coverH,
              foregroundColor: Colors.white,
              backgroundColor: p.primary,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(store.name, overflow: TextOverflow.ellipsis)),
                  const DemoBadge(onDark: true),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: l.share,
                  onPressed: () => context.toast(l.sharedDemo),
                  icon: const Icon(Icons.share_rounded),
                ),
                const CartIconButton(color: Colors.white),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(store.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black54, Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MaxWidth(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.lg, context.pagePadding, 0),
                  child: Row(
                    children: [
                      AppAvatar(store.logo, size: 64),
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
                                    style: context.text.titleLarge,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (store.verified) ...[const SizedBox(width: 4), const VerifiedBadge(compact: true)],
                              ],
                            ),
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
                      const SizedBox(width: Gap.sm),
                      Flexible(
                        child: AnimatedSwitcher(
                          duration: Motion.fast,
                          child: followed
                              ? OutlinedButton.icon(
                                  key: const ValueKey(true),
                                  onPressed: () => ref.read(followedStoresProvider.notifier).toggle(store.id),
                                  icon: const Icon(Icons.check_rounded, size: 18),
                                  label: Text(l.following, maxLines: 1, overflow: TextOverflow.ellipsis),
                                )
                              : FilledButton.icon(
                                  key: const ValueKey(false),
                                  onPressed: () => ref.read(followedStoresProvider.notifier).toggle(store.id),
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: Text(l.follow, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabHeader(
                TabBar(
                  tabAlignment: TabAlignment.fill,
                  tabs: [
                    Tab(text: l.storeProducts),
                    Tab(text: l.storeInfo),
                  ],
                ),
                p.background,
              ),
            ),
          ],
          body: TabBarView(
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth.clamp(0.0, AppBreakpoints.maxContent) - 2 * context.pagePadding;
                  return GridView.builder(
                    padding: EdgeInsets.all(context.pagePadding),
                    gridDelegate: productGridDelegate(context, w),
                    itemCount: items.length,
                    itemBuilder: (_, i) => ProductCard(product: items[i], heroScope: 'store'),
                  );
                },
              ),
              ListView(
                padding: EdgeInsets.all(context.pagePadding),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.about, style: context.text.titleMedium),
                        const SizedBox(height: Gap.sm),
                        Text(store.about),
                        const SizedBox(height: Gap.md),
                        KeyValueRow(l.joined(''), context.digits(DateFormat('MMM yyyy').format(store.joined))),
                        KeyValueRow(l.responseRate, context.digits('${store.responseRate}%')),
                        KeyValueRow(l.shipOnTime, context.digits('96%')),
                        KeyValueRow(l.upazila, upazilaName(store.upazila).of(context)),
                        KeyValueRow(l.storeProducts, context.digits(items.length)),
                      ],
                    ),
                  ),
                  const SizedBox(height: Gap.md),
                  Row(
                    children: [
                      Expanded(
                        child: CallButton(name: store.name, number: store.phone, label: l.call),
                      ),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/shop/chat/${store.id}'),
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          label: Text(l.chat),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabHeader extends SliverPersistentHeaderDelegate {
  _TabHeader(this.tabBar, this.color);
  final TabBar tabBar;
  final Color color;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(
    color: color,
    child: MaxWidth(child: tabBar),
  );

  @override
  bool shouldRebuild(_TabHeader old) => old.tabBar != tabBar || old.color != color;
}
