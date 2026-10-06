import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/state/providers.dart';
import '../../../data/demo/common_data.dart';
import '../../../data/demo/services_data.dart';
import '../../../widgets/widgets.dart';
import '../../shop/product_detail_screen.dart' show ReviewTile;
import '../module_scaffold.dart';

class BusinessListScreen extends StatefulWidget {
  const BusinessListScreen({super.key});

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  String _cat = 'all';
  String _q = '';
  bool _openNow = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = businesses
        .where(
          (b) =>
              (_cat == 'all' || b.category == _cat) &&
              (!_openNow || b.isOpen) &&
              b.name.toLowerCase().contains(_q.toLowerCase()),
        )
        .toList();
    return ModuleScaffold(
      title: l.business,
      mapItems: items,
      markerIcon: Icons.storefront_rounded,
      markerColor: context.palette.primary,
      onOpen: (id) => context.push('/explore/business/$id'),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-business',
        onPressed: () => context.push('/explore/business/add'),
        icon: const Icon(Icons.add_business_rounded),
        label: Text(l.addBusiness),
      ),
      header: Column(
        children: [
          ModuleSearch(hint: l.search, onChanged: (v) => setState(() => _q = v)),
          Row(
            children: [
              Expanded(
                child: FilterChipBar(
                  padding: EdgeInsets.only(left: context.pagePadding),
                  options: ['all', ...businessCategories],
                  selected: _cat,
                  labelOf: (o) => o == 'all' ? l.all : o,
                  onSelected: (v) => setState(() => _cat = v),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding - 8),
            child: SwitchListTile(
              dense: true,
              title: Text(l.open, style: context.text.labelLarge),
              value: _openNow,
              onChanged: (v) => setState(() => _openNow = v),
            ),
          ),
        ],
      ),
      list: (_) => items.isEmpty
          ? EmptyState(icon: Icons.storefront_outlined, title: l.noResults, message: l.noResultsHint)
          : MasterDetail(
              key: ValueKey('$_cat$_q$_openNow'),
              initialId: items.first.id,
              routeFor: (id) => '/explore/business/$id',
              detail: (_, id) => BusinessDetailScreen(id: id, embedded: true),
              list: (context, select, selectedId) => ListView.separated(
                padding: listPadding(context),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
                itemBuilder: (_, i) {
                  final b = items[i];
                  return InfoCard(
                    selected: selectedId == b.id,
                    onTap: () => select(b.id),
                    leading: SizedBox.square(
                      dimension: 72,
                      child: Hero(
                        tag: selectedId == null ? 'biz-${b.id}' : 'biz-list-${b.id}',
                        child: AppImage(b.images.first, radius: Radii.button),
                      ),
                    ),
                    title: b.name,
                    subtitle: b.category,
                    meta: [(Icons.location_on_outlined, '${b.address} · ${upazilaName(b.upazila).of(context)}')],
                    chips: [
                      OpenBadge(isOpen: b.isOpen, is24h: b.hours.contains('24')),
                      RatingLabel(b.rating, suffix: '(${context.compact(b.reviewCount)})'),
                      if (b.verified) const VerifiedBadge(),
                    ],
                    trailing: SaveButton(kind: SavedKind.businesses, id: b.id),
                  );
                },
              ),
            ),
    );
  }
}

class BusinessDetailScreen extends StatelessWidget {
  const BusinessDetailScreen({super.key, required this.id, this.embedded = false});
  final String id;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final b = businesses.firstWhere((x) => x.id == id);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(b.name, overflow: TextOverflow.ellipsis)),
            const DemoBadge(),
          ],
        ),
        actions: [SaveButton(kind: SavedKind.businesses, id: b.id)],
      ),
      body: ListView(
        children: [
          MaxWidth(
            maxWidth: 840,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ImageGallery(images: b.images, aspectRatio: 16 / 9, heroTag: embedded ? null : 'biz-${b.id}'),
                Padding(
                  padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.lg, context.pagePadding, Gap.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(b.name, style: context.text.headlineSmall)),
                          if (b.verified) ...[const SizedBox(width: Gap.xs), const VerifiedBadge(compact: true)],
                        ],
                      ),
                      const SizedBox(height: Gap.xs),
                      Wrap(
                        spacing: Gap.sm,
                        runSpacing: Gap.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Pill(b.category, color: p.info),
                          OpenBadge(isOpen: b.isOpen, is24h: b.hours.contains('24')),
                          RatingStars(b.rating, count: b.reviewCount),
                        ],
                      ),
                      const SizedBox(height: Gap.lg),
                      ContactActions(name: b.name, phone: b.phone),
                      DetailSection(title: l.about, child: ReadMoreText(b.about)),
                      DetailSection(
                        title: l.hours,
                        child: Column(
                          children: [
                            KeyValueRow(l.satThu, context.digits(b.hours)),
                            KeyValueRow(
                              l.friday,
                              context.digits(b.hours.contains('24') ? b.hours : '3:00 PM – 10:00 PM'),
                            ),
                          ],
                        ),
                      ),
                      DetailSection(
                        title: l.address,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('${b.address}, ${upazilaName(b.upazila).of(context)}'),
                            const SizedBox(height: Gap.md),
                            MiniMap(pos: b.pos, title: b.name),
                          ],
                        ),
                      ),
                      DetailSection(
                        title: '${l.reviews} (${context.digits(b.reviewCount)})',
                        trailing: TextButton(onPressed: () => _writeReview(context), child: Text(l.writeReview)),
                        child: Column(children: [for (final r in businessReviews) ReviewTile(review: r)]),
                      ),
                      const SizedBox(height: Gap.md),
                      TextButton.icon(
                        onPressed: () => context.push('/report?item=${Uri.encodeComponent(b.name)}'),
                        icon: Icon(Icons.flag_outlined, color: p.muted),
                        label: Text(l.reportWrongInfo, style: TextStyle(color: p.muted)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _writeReview(BuildContext context) {
    final l = context.l10n;
    var stars = 5;
    showAppSheet<void>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l.writeReview),
            Center(
              child: Wrap(
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      tooltip: '$i',
                      onPressed: () => setS(() => stars = i),
                      icon: Icon(
                        stars >= i ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: const Color(0xFFF5B301),
                        size: 34,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Gap.md),
            const AppTextField(maxLines: 3),
            PrimaryButton(
              label: l.submit,
              onPressed: () {
                Navigator.pop(ctx);
                context.toast(l.reviewSubmitted);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 4-step "Add your business" form with progress indicator.
class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key});

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _forms = List.generate(4, (_) => GlobalKey<FormState>());
  int _step = 0;
  String _category = businessCategories.first;
  String _upazila = upazilas.first.name.en;
  TimeOfDay _open = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _close = const TimeOfDay(hour: 21, minute: 0);
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 3 && !_forms[_step].currentState!.validate()) return;
    if (_step < 3) {
      setState(() => _step++);
    } else {
      context.pushReplacement('/explore/business/pending');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final steps = [l.stepBasic, l.stepContact, l.stepHours, l.stepReview];
    String? req(String? v) => (v == null || v.trim().isEmpty) ? l.required : null;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: AppScaffold(
        title: l.addBusiness,
        bottomBar: Row(
          children: [
            if (_step > 0) ...[
              Expanded(
                child: OutlinedButton(onPressed: () => setState(() => _step--), child: Text(l.back)),
              ),
              const SizedBox(width: Gap.md),
            ],
            Expanded(
              flex: 2,
              child: FilledButton(onPressed: _next, child: Text(_step < 3 ? l.next : l.submit)),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.md, context.pagePadding, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(steps[_step], style: context.text.titleMedium)),
                      Text(
                        context.digits('${_step + 1}/4'),
                        style: context.text.labelLarge?.copyWith(color: p.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: (_step + 1) / 4),
                      duration: Motion.medium,
                      builder: (_, v, _) =>
                          LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: p.surfaceAlt),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(context.pagePadding),
                children: [
                  IndexedStack(
                    index: _step,
                    children: [
                      Form(
                        key: _forms[0],
                        child: Column(
                          children: [
                            AppTextField(
                              label: l.businessName,
                              controller: _name,
                              prefixIcon: Icons.storefront_outlined,
                              validator: req,
                            ),
                            DropdownButtonFormField<String>(
                              initialValue: _category,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l.category,
                                prefixIcon: const Icon(Icons.category_outlined),
                              ),
                              items: [for (final c in businessCategories) DropdownMenuItem(value: c, child: Text(c))],
                              onChanged: (v) => setState(() => _category = v!),
                            ),
                            const SizedBox(height: Gap.lg),
                            AppTextField(label: l.description, maxLines: 3),
                          ],
                        ),
                      ),
                      Form(
                        key: _forms[1],
                        child: Column(
                          children: [
                            AppTextField(
                              label: l.phone,
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                              validator: req,
                            ),
                            DropdownButtonFormField<String>(
                              initialValue: _upazila,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l.upazila,
                                prefixIcon: const Icon(Icons.location_on_outlined),
                              ),
                              items: [
                                for (final u in upazilas)
                                  DropdownMenuItem(value: u.name.en, child: Text(u.name.of(context))),
                              ],
                              onChanged: (v) => setState(() => _upazila = v!),
                            ),
                            const SizedBox(height: Gap.lg),
                            AppTextField(
                              label: l.address,
                              controller: _address,
                              maxLines: 2,
                              prefixIcon: Icons.home_work_outlined,
                              validator: req,
                            ),
                            MiniMap(pos: upazilas.firstWhere((u) => u.name.en == _upazila).pos, title: _upazila),
                          ],
                        ),
                      ),
                      Form(
                        key: _forms[2],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: PickerField(
                                    label: l.openingTime,
                                    icon: Icons.wb_sunny_outlined,
                                    value: _open.format(context),
                                    onTap: () async {
                                      final t = await showTimePicker(context: context, initialTime: _open);
                                      if (t != null) setState(() => _open = t);
                                    },
                                  ),
                                ),
                                const SizedBox(width: Gap.md),
                                Expanded(
                                  child: PickerField(
                                    label: l.closingTime,
                                    icon: Icons.nights_stay_outlined,
                                    value: _close.format(context),
                                    onTap: () async {
                                      final t = await showTimePicker(context: context, initialTime: _close);
                                      if (t != null) setState(() => _close = t);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Text(l.addPhotos, style: context.text.titleSmall),
                            const SizedBox(height: Gap.sm),
                            const PhotoPickerGrid(max: 6, initial: 1, seed: 'newbiz'),
                          ],
                        ),
                      ),
                      Form(
                        key: _forms[3],
                        child: AppCard(
                          child: Column(
                            children: [
                              KeyValueRow(l.businessName, _name.text),
                              KeyValueRow(l.category, _category),
                              KeyValueRow(l.phone, context.digits(_phone.text)),
                              KeyValueRow(l.upazila, upazilaName(_upazila).of(context)),
                              KeyValueRow(l.address, _address.text),
                              KeyValueRow(l.hours, '${_open.format(context)} – ${_close.format(context)}'),
                            ],
                          ),
                        ),
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

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppScaffold(
      title: l.addBusiness,
      body: EmptyState(
        icon: Icons.hourglass_top_rounded,
        color: AppColors.warning,
        title: l.pendingApproval,
        message: l.pendingApprovalBody,
        actionLabel: l.backToHome,
        onAction: () => context.go('/home'),
      ),
    );
  }
}
