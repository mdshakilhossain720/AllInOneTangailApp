import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/demo/shop_data.dart';
import '../../data/models.dart';
import '../../widgets/widgets.dart';
import 'product_detail_screen.dart';
import 'shop_home_screen.dart';

/// Product listing with grid/list toggle, filter and sort sheets.
/// On tablets the grid sits beside the product detail (master-detail).
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({
    super.key,
    this.category,
    this.madeInTangail = false,
    this.flash = false,
    this.focusSearch = false,
    this.storeId,
  });

  final String? category;
  final bool madeInTangail;
  final bool flash;
  final bool focusSearch;
  final String? storeId;

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late ProductFilter _filter = ProductFilter(categories: widget.category == null ? const {} : {widget.category!});
  ProductSort _sort = ProductSort.popular;
  bool _grid = true;
  late bool _searching = widget.focusSearch;
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<Product> get _source {
    var list = products;
    if (widget.madeInTangail) list = list.where((p) => p.madeInTangail).toList();
    if (widget.flash) list = [for (final id in flashSaleIds) productById(id)];
    if (widget.storeId != null) list = list.where((p) => p.storeId == widget.storeId).toList();
    final q = _query.text.trim().toLowerCase();
    if (q.isNotEmpty) list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    return list;
  }

  /// Labelled on roomy screens, icon-only (with tooltip) on narrow phones.
  Widget _toolButton(IconData icon, String label, VoidCallback onTap) {
    if (context.screenWidth < 400) {
      return IconButton(tooltip: label, onPressed: onTap, icon: Icon(icon));
    }
    return TextButton.icon(onPressed: onTap, icon: Icon(icon, size: 18), label: Text(label));
  }

  String get _title {
    final l = context.l10n;
    if (widget.flash) return l.flashSale;
    if (widget.madeInTangail) return l.madeInTangail;
    if (_filter.categories.length == 1) return categoryLabel(l, _filter.categories.first);
    return l.products;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final items = applySort(_source.where(_filter.matches).toList(), _sort);

    final toolbar = Padding(
      padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.sm, context.pagePadding - 8, Gap.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l.itemsCount(context.digits(items.length)),
              style: context.text.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _toolButton(Icons.swap_vert_rounded, l.sort, () async {
            final s = await showSortSheet(context, _sort);
            if (s != null) setState(() => _sort = s);
          }),
          Badge(
            isLabelVisible: _filter.activeCount > 0,
            label: Text(context.digits(_filter.activeCount)),
            backgroundColor: p.primary,
            child: _toolButton(Icons.tune_rounded, l.filter, () async {
              final f = await FilterBottomSheet.show(context, _filter, _source);
              if (f != null) setState(() => _filter = f);
            }),
          ),
          IconButton(
            tooltip: _grid ? l.list : l.grid,
            onPressed: () => setState(() => _grid = !_grid),
            icon: AnimatedSwitcher(
              duration: Motion.fast,
              child: Icon(_grid ? Icons.view_agenda_outlined : Icons.grid_view_rounded, key: ValueKey(_grid)),
            ),
          ),
        ],
      ),
    );

    return AppScaffold(
      maxWidth: false,
      titleWidget: _searching
          ? SearchBarWidget(
              hint: l.shopSearchHint,
              controller: _query,
              autofocus: true,
              elevated: false,
              onChanged: (_) => setState(() {}),
            )
          : null,
      title: _title,
      actions: [
        IconButton(
          tooltip: l.search,
          onPressed: () => setState(() {
            _searching = !_searching;
            if (!_searching) _query.clear();
          }),
          icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
        ),
        const CartIconButton(),
      ],
      body: MasterDetail(
        initialId: items.isEmpty ? null : items.first.id,
        listWidth: 520,
        routeFor: (id) => '/shop/product/$id?h=list',
        detail: (_, id) => ProductDetailScreen(productId: id, embedded: true, heroScope: 'list'),
        list: (context, select, selectedId) => Column(
          children: [
            toolbar,
            Expanded(
              child: items.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off_rounded,
                      title: l.noResults,
                      message: l.noResultsHint,
                      actionLabel: l.reset,
                      onAction: () => setState(() {
                        _filter = const ProductFilter();
                        _query.clear();
                      }),
                    )
                  : DemoLoader(
                      skeleton: _grid ? const LoadingShimmer.grid() : const LoadingShimmer.list(),
                      builder: (_) => LayoutBuilder(
                        builder: (context, c) => AnimatedSwitcher(
                          duration: Motion.medium,
                          child: _grid
                              ? GridView.builder(
                                  key: const ValueKey('grid'),
                                  padding: EdgeInsets.fromLTRB(context.pagePadding, 0, context.pagePadding, Gap.xxl),
                                  gridDelegate: productGridDelegate(context, c.maxWidth - 2 * context.pagePadding),
                                  itemCount: items.length,
                                  itemBuilder: (_, i) => ProductCard(
                                    product: items[i],
                                    heroScope: 'list',
                                    selected: selectedId == items[i].id,
                                    onTap: selectedId == null ? null : () => select(items[i].id),
                                  ),
                                )
                              : ListView.separated(
                                  key: const ValueKey('list'),
                                  padding: EdgeInsets.fromLTRB(context.pagePadding, 0, context.pagePadding, Gap.xxl),
                                  itemCount: items.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
                                  itemBuilder: (_, i) => ProductListTile(
                                    product: items[i],
                                    selected: selectedId == items[i].id,
                                    onTap: selectedId == null ? null : () => select(items[i].id),
                                  ),
                                ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
