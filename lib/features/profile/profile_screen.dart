import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/common_data.dart';
import '../../widgets/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final name = ref.watch(userNameProvider);
    final isSeller = ref.watch(isSellerProvider);
    final orders = ref.watch(ordersProvider);
    final stats = [
      (context.digits(orders.length), l.myOrders, Icons.receipt_long_rounded, '/orders'),
      (context.digits(ref.watch(wishlistProvider).length), l.wishlist, Icons.favorite_rounded, '/saved'),
      (context.digits(ref.watch(coinsProvider)), l.coins, Icons.monetization_on_rounded, '/wallet'),
    ];

    final groups = <(String, List<_MenuItem>)>[
      (
        l.groupShopping,
        [
          _MenuItem(Icons.receipt_long_outlined, l.myOrders, route: '/orders'),
          _MenuItem(Icons.confirmation_number_outlined, l.vouchersWallet, route: '/wallet'),
          _MenuItem(Icons.location_on_outlined, l.addresses, route: '/addresses'),
          _MenuItem(
            Icons.storefront_outlined,
            isSeller ? l.sellerCenter : l.becomeSeller,
            route: isSeller ? '/seller' : '/seller/onboarding',
            badge: isSeller ? null : l.open,
          ),
        ],
      ),
      (
        l.groupCommunity,
        [
          _MenuItem(Icons.list_alt_rounded, l.myListings, route: '/my-listings'),
          _MenuItem(Icons.bloodtype_outlined, l.donorProfile, route: '/donor-profile', color: p.emergency),
        ],
      ),
      (
        l.groupPreferences,
        [
          _MenuItem(Icons.settings_outlined, l.settings, route: '/settings'),
          _MenuItem(
            Icons.translate_rounded,
            l.language,
            trailing: context.isBn ? 'বাংলা' : 'English',
            route: '/settings',
          ),
        ],
      ),
      (
        l.groupSupport,
        [
          _MenuItem(Icons.flag_outlined, l.reportWrongInfo, route: '/report'),
          _MenuItem(Icons.help_outline_rounded, l.helpSupport, route: '/help'),
          _MenuItem(Icons.info_outline_rounded, l.aboutApp, route: '/about'),
        ],
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(l.navProfile)),
                const DemoBadge(),
              ],
            ),
            actions: [
              IconButton(
                tooltip: l.settings,
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: MaxWidth(
              maxWidth: 840,
              child: Padding(
                padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.sm, context.pagePadding, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header card.
                    Container(
                      padding: const EdgeInsets.all(Gap.lg),
                      decoration: BoxDecoration(gradient: p.headerGradient, borderRadius: Radii.cardBorder),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              const CircleAvatar(
                                radius: 34,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 31,
                                  backgroundImage: null,
                                  child: Icon(Icons.person_rounded, size: 36),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: p.emergency,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Text(
                                    'O+',
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: Gap.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: context.text.titleLarge?.copyWith(color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  context.digits('+880 1700-000001'),
                                  style: context.text.bodySmall?.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: Gap.xs,
                                  runSpacing: Gap.xs,
                                  children: [
                                    Pill(
                                      upazilaById(ref.watch(upazilaProvider)).name.of(context),
                                      color: Colors.white,
                                      icon: Icons.location_on_rounded,
                                      dense: true,
                                    ),
                                    Pill(l.memberSince(context.digits(2024)), color: Colors.white, dense: true),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: l.editProfile,
                            onPressed: () => _editProfile(context, ref),
                            icon: const Icon(Icons.edit_rounded, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Gap.md),
                    // Quick stats.
                    AppCard(
                      padding: const EdgeInsets.symmetric(vertical: Gap.md),
                      child: Row(
                        children: [
                          for (final (i, (value, label, icon, route)) in stats.indexed) ...[
                            if (i > 0) Container(width: 1, height: 40, color: p.border),
                            Expanded(
                              child: InkWell(
                                borderRadius: Radii.buttonBorder,
                                onTap: () => route == '/saved' ? context.go(route) : context.push(route),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: Gap.xs),
                                  child: Column(
                                    children: [
                                      Icon(icon, color: [p.primary, p.emergency, const Color(0xFFD9772B)][i]),
                                      FittedBox(child: Text(value, style: context.text.titleLarge)),
                                      Text(
                                        label,
                                        style: context.text.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    for (final (title, items) in groups) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Gap.xs, Gap.xl, Gap.xs, Gap.sm),
                        child: Text(title, style: context.text.labelLarge?.copyWith(color: p.muted)),
                      ),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (final (i, item) in items.indexed) ...[
                              if (i > 0) Divider(height: 1, indent: 56, color: p.border),
                              ListTile(
                                leading: Icon(item.icon, color: item.color ?? p.primary),
                                title: Text(item.label),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (item.badge != null) Pill(item.badge!, color: p.success, dense: true),
                                    if (item.trailing != null) Text(item.trailing!, style: context.text.bodySmall),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                                onTap: () => context.push(item.route),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: Gap.xl),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: p.emergency,
                        side: BorderSide(color: p.emergency.withValues(alpha: 0.5)),
                      ),
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(l.logout),
                    ),
                    const SizedBox(height: Gap.md),
                    Text(
                      l.version(context.digits('1.0.0 (demo)')),
                      textAlign: TextAlign.center,
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = TextEditingController(text: ref.read(userNameProvider));
    showAppSheet<void>(
      context,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetTitle(l.editProfile),
          AppTextField(label: l.name, controller: c, prefixIcon: Icons.person_outline_rounded),
          const AppTextField(initialValue: '01700000001', prefixIcon: Icons.phone_outlined, readOnly: true),
          PrimaryButton(
            label: l.save,
            onPressed: () {
              if (c.text.trim().isNotEmpty) ref.read(userNameProvider.notifier).set(c.text.trim());
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    ).whenComplete(c.dispose);
  }

  Future<void> _logout(BuildContext context) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.logout_rounded, color: ctx.palette.emergency),
        title: Text(l.logout),
        content: Text(l.logoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: ctx.palette.emergency),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.logout),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) context.go('/login');
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.label, {required this.route, this.trailing, this.badge, this.color});
  final IconData icon;
  final String label;
  final String route;
  final String? trailing;
  final String? badge;
  final Color? color;
}
