import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/common_data.dart';
import '../../data/demo/health_data.dart';
import '../../data/demo/services_data.dart';
import '../../widgets/widgets.dart';
import '../explore/health/doctors_screen.dart' show DoctorCard;
import '../explore/legal/lawyers_screen.dart' show LawyerCard;
import '../explore/travel/tourism_screen.dart' show PlaceTile, StaggeredGrid;
import '../shop/shop_home_screen.dart' show productGridDelegate;

/// Saved items: Products (wishlist), Doctors, Lawyers, Businesses, Places.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final saved = ref.watch(savedProvider);
    final wishlist = ref.watch(wishlistProvider);
    int count(SavedKind k) => k == SavedKind.products ? wishlist.length : (saved[k]?.length ?? 0);
    final tabs = [
      (SavedKind.products, l.products, Icons.favorite_rounded),
      (SavedKind.doctors, l.doctors, Icons.medical_services_rounded),
      (SavedKind.lawyers, l.lawyers, Icons.gavel_rounded),
      (SavedKind.businesses, l.businesses, Icons.storefront_rounded),
      (SavedKind.places, l.places, Icons.landscape_rounded),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(l.savedTitle)),
              const DemoBadge(),
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final (k, label, icon) in tabs)
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18),
                      const SizedBox(width: 6),
                      Text('$label (${context.digits(count(k))})'),
                    ],
                  ),
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: [for (final (k, _, icon) in tabs) _SavedTab(kind: k, icon: icon)],
        ),
      ),
    );
  }
}

class _SavedTab extends ConsumerWidget {
  const _SavedTab({required this.kind, required this.icon});
  final SavedKind kind;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final ids = kind == SavedKind.products
        ? ref.watch(wishlistProvider)
        : (ref.watch(savedProvider)[kind] ?? const <String>{});
    if (ids.isEmpty) {
      final (route, label) = switch (kind) {
        SavedKind.products => ('/shop', l.startShopping),
        SavedKind.doctors => ('/explore/doctors', l.doctors),
        SavedKind.lawyers => ('/explore/lawyers', l.lawyers),
        SavedKind.businesses => ('/explore/business', l.business),
        SavedKind.places => ('/explore/tourism', l.tourism),
      };
      return EmptyState(
        icon: icon,
        title: l.emptySaved,
        message: l.emptySavedHint,
        actionLabel: label,
        onAction: () => kind == SavedKind.products ? context.go(route) : context.push(route),
      );
    }
    final pad = EdgeInsets.fromLTRB(context.pagePadding, Gap.md, context.pagePadding, 100);
    return MaxWidth(
      child: switch (kind) {
        SavedKind.products => LayoutBuilder(
          builder: (context, c) {
            final items = [for (final id in ids) resolveProduct(ref, id)];
            return GridView.builder(
              padding: pad,
              gridDelegate: productGridDelegate(context, c.maxWidth - 2 * context.pagePadding),
              itemCount: items.length,
              itemBuilder: (_, i) => ProductCard(product: items[i], heroScope: 'saved'),
            );
          },
        ),
        SavedKind.doctors => ListView(
          padding: pad,
          children: [
            for (final d in doctors.where((d) => ids.contains(d.id))) ...[
              DoctorCard(doctor: d),
              const SizedBox(height: Gap.md),
            ],
          ],
        ),
        SavedKind.lawyers => ListView(
          padding: pad,
          children: [
            for (final x in lawyers.where((x) => ids.contains(x.id))) ...[
              LawyerCard(lawyer: x, onTap: () => context.push('/explore/lawyers/${x.id}')),
              const SizedBox(height: Gap.md),
            ],
          ],
        ),
        SavedKind.businesses => ListView(
          padding: pad,
          children: [
            for (final b in businesses.where((b) => ids.contains(b.id))) ...[
              InfoCard(
                onTap: () => context.push('/explore/business/${b.id}'),
                leading: SizedBox.square(dimension: 64, child: AppImage(b.images.first, radius: Radii.button)),
                title: b.name,
                subtitle: b.category,
                chips: [
                  OpenBadge(isOpen: b.isOpen),
                  RatingLabel(b.rating),
                ],
                trailing: SaveButton(kind: SavedKind.businesses, id: b.id),
              ),
              const SizedBox(height: Gap.md),
            ],
          ],
        ),
        SavedKind.places => SingleChildScrollView(
          padding: pad,
          child: LayoutBuilder(
            builder: (context, c) => StaggeredGrid(
              columns: AppBreakpoints.value(c.maxWidth, compact: 2, phone: 2, largePhone: 3, tablet: 4),
              children: [for (final p in places.where((p) => ids.contains(p.id))) PlaceTile(place: p)],
            ),
          ),
        ),
      },
    );
  }
}
