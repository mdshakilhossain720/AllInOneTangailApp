import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/common_data.dart';
import '../../data/demo/health_data.dart';
import '../../data/demo/services_data.dart';
import '../../data/demo/shop_data.dart';
import '../../widgets/widgets.dart';

class _Hit {
  const _Hit(this.title, this.subtitle, this.route, {this.image, this.icon});
  final String title;
  final String subtitle;
  final String route;
  final String? image;
  final IconData? icon;
}

/// Global search with Bangla/English input, voice (UI only), recent and
/// trending searches, and results grouped by module.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.startWithVoice = false, this.initialQuery = ''});
  final bool startWithVoice;
  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final _controller = TextEditingController(text: widget.initialQuery);
  String get _q => _controller.text.trim();

  @override
  void initState() {
    super.initState();
    if (widget.startWithVoice) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _voice());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    ref.read(recentSearchesProvider.notifier).push(q);
    setState(() {});
  }

  Future<void> _voice() async {
    final result = await showModalBottomSheet<String>(context: context, builder: (_) => const _VoiceSheet());
    if (result != null && mounted) _search(result);
  }

  bool _match(String s) {
    final q = _q.toLowerCase();
    // Bangla aliases so Bangla queries hit English demo data.
    const aliases = {
      'শাড়ি': 'saree',
      'চমচম': 'chomchom',
      'ডাক্তার': 'dr',
      'হাসপাতাল': 'hospital',
      'আইনজীবী': 'adv',
      'বাস': 'bus',
      'মহেড়া': 'mohera',
      'জমিদার': 'zamindar',
      'মধু': 'honey',
      'আনারস': 'pineapple',
    };
    final s2 = s.toLowerCase();
    if (s2.contains(q)) return true;
    for (final e in aliases.entries) {
      if (q.contains(e.key) && s2.contains(e.value)) return true;
    }
    return false;
  }

  Map<String, List<_Hit>> _results() {
    final l = context.l10n;
    return {
      l.products: [
        for (final p in products.where((p) => _match(p.name) || _match(p.categoryId)))
          _Hit(p.name, context.taka(p.price), '/shop/product/${p.id}', image: p.images.first),
      ],
      l.doctors: [
        for (final d in doctors.where((d) => _match(d.name) || _match(d.specialty)))
          _Hit(d.name, d.specialty, '/explore/doctors/${d.id}', image: d.image),
      ],
      l.hospitals: [
        for (final h in hospitals.where((h) => _match(h.name)))
          _Hit(h.name, h.address, '/explore/hospitals/${h.id}', icon: Icons.local_hospital_rounded),
      ],
      l.lawyers: [
        for (final x in lawyers.where((x) => _match(x.name) || x.areas.any(_match)))
          _Hit(x.name, x.areas.join(' · '), '/explore/lawyers/${x.id}', image: x.image),
      ],
      l.businesses: [
        for (final b in businesses.where((b) => _match(b.name) || _match(b.category)))
          _Hit(b.name, b.category, '/explore/business/${b.id}', image: b.images.first),
      ],
      l.places: [
        for (final p in places.where((p) => _match(p.name)))
          _Hit(p.name, p.upazila, '/explore/tourism/${p.id}', image: p.image),
      ],
      l.services: [
        if (_match('bus') || _match('dhaka') || _match('transport'))
          _Hit(l.busRoutes, 'Tangail → Dhaka', '/explore/transport', icon: Icons.directions_bus_rounded),
        if (_match('blood') || _match('রক্ত'))
          _Hit(l.bloodDonors, l.requestBlood, '/explore/blood', icon: Icons.bloodtype_rounded),
        for (final j in jobs.where((j) => _match(j.title)))
          _Hit(j.title, j.company, '/explore/jobs/${j.id}', icon: Icons.work_outline_rounded),
      ],
      l.news: [
        for (final n in newsArticles.where((n) => _match(n.title)))
          _Hit(n.title, n.source, '/explore/news/${n.id}', image: n.image),
      ],
    }..removeWhere((_, v) => v.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: Gap.md),
          child: SearchBarWidget(
            hint: l.searchHint,
            controller: _controller,
            autofocus: !widget.startWithVoice && widget.initialQuery.isEmpty,
            elevated: false,
            onChanged: (_) => setState(() {}),
            onSubmitted: _search,
            onMic: _voice,
            trailing: _q.isEmpty
                ? null
                : IconButton(
                    tooltip: l.clearAll,
                    onPressed: () => setState(_controller.clear),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: MaxWidth(maxWidth: 840, child: _q.isEmpty ? _suggestions(context) : _resultsList(context)),
      ),
    );
  }

  Widget _suggestions(BuildContext context) {
    final l = context.l10n;
    final recent = ref.watch(recentSearchesProvider);
    return ListView(
      padding: const EdgeInsets.all(Gap.lg),
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(child: Text(l.recentSearches, style: context.text.titleMedium)),
              TextButton(onPressed: () => ref.read(recentSearchesProvider.notifier).clear(), child: Text(l.clearAll)),
            ],
          ),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              for (final r in recent)
                InputChip(
                  avatar: const Icon(Icons.history_rounded, size: 16),
                  label: Text(r),
                  onPressed: () => _search(r),
                  onDeleted: () => ref.read(recentSearchesProvider.notifier).remove(r),
                ),
            ],
          ),
          const SizedBox(height: Gap.xl),
        ],
        Text(l.trendingSearches, style: context.text.titleMedium),
        const SizedBox(height: Gap.sm),
        for (final (i, t) in trendingSearches.indexed)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: i < 3 ? context.palette.secondarySoft : context.palette.surfaceAlt,
              child: Text(context.digits(i + 1), style: context.text.labelMedium),
            ),
            title: Text(t),
            trailing: Icon(Icons.trending_up_rounded, color: i < 3 ? context.palette.emergency : context.palette.muted),
            onTap: () => _search(t),
          ),
      ],
    );
  }

  Widget _resultsList(BuildContext context) {
    final groups = _results();
    if (groups.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: context.l10n.noResults,
        message: context.l10n.noResultsHint,
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: Gap.xl),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.lg, 0),
          child: Text(context.l10n.resultsFor(_q), style: context.text.bodySmall),
        ),
        for (final e in groups.entries) ...[
          SectionHeader(
            '${e.key} (${context.digits(e.value.length)})',
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.xs),
          ),
          for (final h in e.value.take(4))
            ListTile(
              leading: h.image != null
                  ? SizedBox.square(dimension: 48, child: AppImage(h.image!, radius: 10))
                  : PastelIcon(h.icon ?? Icons.search_rounded, index: e.key.length, size: 48),
              title: Text(h.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(h.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.north_west_rounded, size: 18),
              onTap: () {
                ref.read(recentSearchesProvider.notifier).push(_q);
                context.push(h.route);
              },
            ),
        ],
      ],
    );
  }
}

/// Fake voice capture: pulsing mic, then returns a demo phrase.
class _VoiceSheet extends StatefulWidget {
  const _VoiceSheet();

  @override
  State<_VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends State<_VoiceSheet> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) Navigator.pop(context, context.isBn ? 'চমচম' : 'Chomchom');
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.voiceListening, style: context.text.headlineSmall),
            const SizedBox(height: Gap.xs),
            Text(context.l10n.voiceHint, style: context.text.bodySmall),
            const SizedBox(height: Gap.xl),
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, _) => Container(
                width: 96 + 24 * _pulse.value,
                height: 96 + 24 * _pulse.value,
                decoration: BoxDecoration(color: p.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: p.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.mic_rounded, color: Colors.white, size: 36),
                ),
              ),
            ),
            const SizedBox(height: Gap.lg),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
          ],
        ),
      ),
    );
  }
}
