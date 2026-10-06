import 'package:material_ui/material_ui.dart';

import '../core/theme/tokens.dart';
import '../core/utils/context_ext.dart';
import '../data/demo/common_data.dart';
import '../data/demo/shop_data.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';

enum ProductSort { popular, newest, priceLow, priceHigh }

@immutable
class ProductFilter {
  const ProductFilter({
    this.price = const RangeValues(0, 10000),
    this.categories = const {},
    this.minRating = 0,
    this.upazila,
    this.delivery = const {},
    this.inStockOnly = false,
  });

  final RangeValues price;
  final Set<String> categories;
  final double minRating;
  final String? upazila;
  final Set<String> delivery; // 'home', 'pickup'
  final bool inStockOnly;

  static const maxPrice = 10000.0;

  int get activeCount =>
      (price.start > 0 || price.end < maxPrice ? 1 : 0) +
      (categories.isNotEmpty ? 1 : 0) +
      (minRating > 0 ? 1 : 0) +
      (upazila != null ? 1 : 0) +
      (delivery.isNotEmpty ? 1 : 0) +
      (inStockOnly ? 1 : 0);

  bool matches(Product p) =>
      p.price >= price.start &&
      p.price <= price.end &&
      (categories.isEmpty || categories.contains(p.categoryId)) &&
      p.rating >= minRating &&
      (upazila == null || p.upazila == upazila) &&
      (!delivery.contains('pickup') || p.pickup) &&
      (!inStockOnly || p.stock > 0);

  ProductFilter copyWith({
    RangeValues? price,
    Set<String>? categories,
    double? minRating,
    String? upazila,
    bool clearUpazila = false,
    Set<String>? delivery,
    bool? inStockOnly,
  }) => ProductFilter(
    price: price ?? this.price,
    categories: categories ?? this.categories,
    minRating: minRating ?? this.minRating,
    upazila: clearUpazila ? null : (upazila ?? this.upazila),
    delivery: delivery ?? this.delivery,
    inStockOnly: inStockOnly ?? this.inStockOnly,
  );
}

List<Product> applySort(List<Product> list, ProductSort sort) {
  final l = [...list];
  switch (sort) {
    case ProductSort.popular:
      l.sort((a, b) => b.sold.compareTo(a.sold));
    case ProductSort.newest:
      l.sort((a, b) => a.daysAgo.compareTo(b.daysAgo));
    case ProductSort.priceLow:
      l.sort((a, b) => a.price.compareTo(b.price));
    case ProductSort.priceHigh:
      l.sort((a, b) => b.price.compareTo(a.price));
  }
  return l;
}

String categoryLabel(AppLocalizations l, String id) => switch (id) {
  'saree' => l.catSaree,
  'food' => l.catFood,
  'fashion' => l.catFashion,
  'electronics' => l.catElectronics,
  'home' => l.catHome,
  'agri' => l.catAgri,
  'craft' => l.catCraft,
  'books' => l.catBooks,
  _ => id,
};

String sortLabel(AppLocalizations l, ProductSort s) => switch (s) {
  ProductSort.popular => l.sortPopular,
  ProductSort.newest => l.sortNewest,
  ProductSort.priceLow => l.sortPriceLow,
  ProductSort.priceHigh => l.sortPriceHigh,
};

Future<ProductSort?> showSortSheet(BuildContext context, ProductSort current) {
  return showModalBottomSheet<ProductSort>(
    context: context,
    builder: (ctx) => SafeArea(
      child: RadioGroup<ProductSort>(
        groupValue: current,
        onChanged: (v) => Navigator.pop(ctx, v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(ctx.l10n.sort, style: ctx.text.headlineSmall),
              ),
            ),
            const SizedBox(height: Gap.sm),
            for (final s in ProductSort.values)
              RadioListTile<ProductSort>(
                value: s,
                title: Text(sortLabel(ctx.l10n, s)),
                contentPadding: const EdgeInsets.symmetric(horizontal: Gap.lg),
              ),
            const SizedBox(height: Gap.md),
          ],
        ),
      ),
    ),
  );
}

/// Product filter sheet: price range slider, category, rating, upazila,
/// delivery type and stock. Shows a live result count on the apply button.
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key, required this.initial, required this.source});

  final ProductFilter initial;
  final List<Product> source;

  static Future<ProductFilter?> show(BuildContext context, ProductFilter initial, List<Product> source) {
    return showModalBottomSheet<ProductFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) => FilterBottomSheet(initial: initial, source: source),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late ProductFilter f = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final count = widget.source.where(f.matches).length;

    Widget title(String t) => Padding(
      padding: const EdgeInsets.only(top: Gap.lg, bottom: Gap.sm),
      child: Text(t, style: context.text.titleMedium),
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
            child: Row(
              children: [
                Expanded(child: Text(l.filter, style: context.text.headlineSmall)),
                TextButton(onPressed: () => setState(() => f = const ProductFilter()), child: Text(l.reset)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
              children: [
                title(l.priceRange),
                RangeSlider(
                  values: f.price,
                  max: ProductFilter.maxPrice,
                  divisions: 40,
                  labels: RangeLabels(context.taka(f.price.start), context.taka(f.price.end)),
                  onChanged: (v) => setState(() => f = f.copyWith(price: v)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.taka(f.price.start), style: context.text.labelMedium),
                    Text(context.taka(f.price.end), style: context.text.labelMedium),
                  ],
                ),
                title(l.category),
                Wrap(
                  spacing: Gap.sm,
                  runSpacing: Gap.sm,
                  children: [
                    for (final c in shopCategories)
                      FilterChip(
                        label: Text(categoryLabel(l, c.id)),
                        avatar: Icon(c.icon, size: 16),
                        selected: f.categories.contains(c.id),
                        onSelected: (v) => setState(() {
                          final s = {...f.categories};
                          v ? s.add(c.id) : s.remove(c.id);
                          f = f.copyWith(categories: s);
                        }),
                      ),
                  ],
                ),
                title(l.minRating),
                Wrap(
                  spacing: Gap.sm,
                  children: [
                    for (final r in [0.0, 3.0, 4.0, 4.5])
                      ChoiceChip(
                        label: Text(r == 0 ? l.all : '${context.digits(r)}★+'),
                        selected: f.minRating == r,
                        onSelected: (_) => setState(() => f = f.copyWith(minRating: r)),
                      ),
                  ],
                ),
                title(l.upazila),
                DropdownButtonFormField<String?>(
                  initialValue: f.upazila,
                  isExpanded: true,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined)),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l.allUpazilas)),
                    for (final u in upazilas) DropdownMenuItem(value: u.name.en, child: Text(u.name.of(context))),
                  ],
                  onChanged: (v) =>
                      setState(() => f = v == null ? f.copyWith(clearUpazila: true) : f.copyWith(upazila: v)),
                ),
                title(l.deliveryType),
                Wrap(
                  spacing: Gap.sm,
                  children: [
                    for (final (key, label, icon) in [
                      ('home', l.homeDelivery, Icons.local_shipping_outlined),
                      ('pickup', l.localPickup, Icons.storefront_outlined),
                    ])
                      FilterChip(
                        avatar: Icon(icon, size: 16),
                        label: Text(label),
                        selected: f.delivery.contains(key),
                        onSelected: (v) => setState(() {
                          final s = {...f.delivery};
                          v ? s.add(key) : s.remove(key);
                          f = f.copyWith(delivery: s);
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: Gap.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.inStockOnly),
                  value: f.inStockOnly,
                  onChanged: (v) => setState(() => f = f.copyWith(inStockOnly: v)),
                ),
                const SizedBox(height: Gap.xl),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: p.border)),
            ),
            padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.md, Gap.xl, Gap.md),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, f),
                  child: Text(l.showResults(context.digits(count))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
