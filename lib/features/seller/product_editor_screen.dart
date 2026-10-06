import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/shop_data.dart';
import '../../data/models.dart';
import '../../widgets/widgets.dart';

/// Add / edit product: images (up to 6), name, category, variants, price,
/// discount price, stock, description, delivery options, preview.
class ProductEditorScreen extends ConsumerStatefulWidget {
  const ProductEditorScreen({super.key, this.productId});
  final String? productId;

  @override
  ConsumerState<ProductEditorScreen> createState() => _ProductEditorScreenState();
}

class _ProductEditorScreenState extends ConsumerState<ProductEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final Product? _existing = widget.productId == null
      ? null
      : ref.read(sellerProductsProvider).where((p) => p.id == widget.productId).firstOrNull;

  late final _name = TextEditingController(text: _existing?.name ?? '');
  late final _price = TextEditingController(text: _existing == null ? '' : '${_existing.oldPrice ?? _existing.price}');
  late final _discount = TextEditingController(text: _existing?.oldPrice == null ? '' : '${_existing!.price}');
  late final _stock = TextEditingController(text: _existing == null ? '10' : '${_existing.stock}');
  late final _desc = TextEditingController(text: _existing?.description ?? '');
  late String _category = _existing?.categoryId ?? 'saree';
  late final List<String> _variants = [...?_existing?.sizes];
  bool _home = true;
  bool _pickup = true;

  @override
  void dispose() {
    for (final c in [_name, _price, _discount, _stock, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  Product _build() {
    final regular = int.tryParse(_price.text) ?? 0;
    final discounted = int.tryParse(_discount.text);
    final hasDiscount = discounted != null && discounted > 0 && discounted < regular;
    final base = _existing ?? products.first;
    return Product(
      id: _existing?.id ?? 'new${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim().isEmpty ? '—' : _name.text.trim(),
      categoryId: _category,
      price: hasDiscount ? discounted : regular,
      oldPrice: hasDiscount ? regular : null,
      rating: _existing?.rating ?? 0,
      sold: _existing?.sold ?? 0,
      storeId: 's1',
      upazila: 'Delduar',
      verified: true,
      images: _existing?.images ?? [for (var i = 0; i < 3; i++) 'https://picsum.photos/seed/newprod$i/600/600'],
      sizes: _variants,
      colors: base.colors,
      stock: int.tryParse(_stock.text) ?? 0,
      description: _desc.text.trim(),
      specs: base.specs,
      madeInTangail: true,
      pickup: _pickup,
      daysAgo: 0,
    );
  }

  void _save({required bool publish}) {
    final l = context.l10n;
    if (!_form.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }
    final p = _build();
    ref.read(sellerProductsProvider.notifier).upsert(p);
    final unpublished = ref.read(unpublishedProductsProvider).contains(p.id);
    if (publish == unpublished) ref.read(unpublishedProductsProvider.notifier).toggle(p.id);
    context.toast(publish ? '${l.productSaved} · ${l.published}' : '${l.productSaved} · ${l.draft}');
    context.pop();
  }

  Future<void> _addVariant() async {
    final l = context.l10n;
    final c = TextEditingController();
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.addVariant),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: InputDecoration(hintText: context.isBn ? 'যেমন: L, ৫০০ গ্রাম' : 'e.g. L, 500 g'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: Text(l.save)),
        ],
      ),
    );
    if (v != null && v.isNotEmpty) setState(() => _variants.add(v));
  }

  void _preview() {
    final p = _build();
    showAppSheet<void>(
      context,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetTitle(ctx.l10n.preview),
          Center(
            child: SizedBox(
              width: 200,
              child: AbsorbPointer(
                child: ProductCard(product: p, heroScope: 'preview'),
              ),
            ),
          ),
          const SizedBox(height: Gap.lg),
          AbsorbPointer(child: ProductListTile(product: p)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String? req(String? v) => (v == null || v.trim().isEmpty) ? l.required : null;
    String? number(String? v) => (int.tryParse(v ?? '') == null) ? l.required : null;
    final inputDigits = [FilteringTextInputFormatter.digitsOnly];

    return AppScaffold(
      title: _existing == null ? l.addProduct : l.editProduct,
      actions: [
        TextButton.icon(onPressed: _preview, icon: const Icon(Icons.visibility_outlined), label: Text(l.preview)),
      ],
      bottomBar: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _save(publish: false),
              child: Text(l.save, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: () => _save(publish: true),
              child: Text(l.publish, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            Text(l.photosCount(context.digits(_existing == null ? 3 : 4)), style: context.text.titleSmall),
            const SizedBox(height: Gap.sm),
            PhotoPickerGrid(max: 6, initial: _existing == null ? 3 : 4, seed: _existing?.id ?? 'newprod'),
            const SizedBox(height: Gap.xl),
            AppTextField(label: l.productName, controller: _name, validator: req, maxLength: 80),
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.lg),
              child: DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.category, prefixIcon: const Icon(Icons.category_outlined)),
                items: [
                  for (final c in shopCategories)
                    DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          Icon(c.icon, size: 18),
                          const SizedBox(width: Gap.sm),
                          Flexible(child: Text(categoryLabel(l, c.id))),
                        ],
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: '${l.price} (৳)',
                    controller: _price,
                    keyboardType: TextInputType.number,
                    inputFormatters: inputDigits,
                    validator: number,
                  ),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: AppTextField(
                    label: '${l.discountPrice} (৳)',
                    controller: _discount,
                    keyboardType: TextInputType.number,
                    inputFormatters: inputDigits,
                  ),
                ),
              ],
            ),
            AppTextField(
              label: l.stock,
              controller: _stock,
              keyboardType: TextInputType.number,
              inputFormatters: inputDigits,
              validator: number,
              prefixIcon: Icons.inventory_2_outlined,
            ),
            Text(l.variants, style: context.text.titleSmall),
            const SizedBox(height: Gap.sm),
            Wrap(
              spacing: Gap.sm,
              runSpacing: Gap.sm,
              children: [
                for (final v in _variants)
                  InputChip(label: Text(v), onDeleted: () => setState(() => _variants.remove(v))),
                ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l.addVariant),
                  onPressed: _addVariant,
                ),
              ],
            ),
            const SizedBox(height: Gap.xl),
            AppTextField(label: l.description, controller: _desc, maxLines: 5, validator: req),
            Text(l.deliveryOptions, style: context.text.titleSmall),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _home,
              onChanged: (v) => setState(() => _home = v!),
              title: Text(l.homeDelivery),
              secondary: const Icon(Icons.local_shipping_outlined),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _pickup,
              onChanged: (v) => setState(() => _pickup = v!),
              title: Text(l.localPickup),
              secondary: const Icon(Icons.storefront_outlined),
            ),
            const SizedBox(height: Gap.xl),
          ],
        ),
      ),
    );
  }
}
