import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo/common_data.dart';
import '../../../data/demo/health_data.dart';
import '../../../widgets/widgets.dart';
import '../module_scaffold.dart';

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({super.key});

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  String _filter = 'all';
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final items = hospitals.where((h) {
      final f = switch (_filter) {
        'govt' => h.isGovt,
        'private' => !h.isGovt,
        'emergency' => h.emergency24,
        _ => true,
      };
      return f && h.name.toLowerCase().contains(_q.toLowerCase());
    }).toList();

    return ModuleScaffold(
      title: l.hospitals,
      mapItems: items,
      markerIcon: Icons.local_hospital_rounded,
      onOpen: (id) => context.push('/explore/hospitals/$id'),
      header: Column(
        children: [
          ModuleSearch(hint: l.search, onChanged: (v) => setState(() => _q = v)),
          FilterChipBar(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            options: const ['all', 'govt', 'private', 'emergency'],
            selected: _filter,
            labelOf: (o) => switch (o) {
              'govt' => l.govt,
              'private' => l.privateLabel,
              'emergency' => l.emergencyAvailable,
              _ => l.all,
            },
            onSelected: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: Gap.sm),
        ],
      ),
      list: (_) => items.isEmpty
          ? EmptyState(icon: Icons.local_hospital_outlined, title: l.noResults, message: l.noResultsHint)
          : ListView.separated(
              padding: listPadding(context),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
              itemBuilder: (_, i) {
                final h = items[i];
                return InfoCard(
                  onTap: () => context.push('/explore/hospitals/${h.id}'),
                  leading: SizedBox.square(
                    dimension: 72,
                    child: Hero(
                      tag: 'hospital-${h.id}',
                      child: AppImage(h.image, radius: Radii.button),
                    ),
                  ),
                  title: h.name,
                  meta: [
                    (Icons.location_on_outlined, '${h.address} · ${upazilaName(h.upazila).of(context)}'),
                    (Icons.bed_outlined, l.beds(context.digits(h.beds))),
                  ],
                  chips: [
                    Pill(h.isGovt ? l.govt : l.privateLabel, color: h.isGovt ? p.info : p.primary, dense: true),
                    if (h.emergency24)
                      Pill(l.emergencyAvailable, color: p.emergency, icon: Icons.emergency_rounded, dense: true),
                    RatingLabel(h.rating),
                  ],
                  trailing: CallButton(name: h.name, number: h.phone),
                );
              },
            ),
    );
  }
}

class HospitalDetailScreen extends StatelessWidget {
  const HospitalDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final h = hospitals.firstWhere((x) => x.id == id);
    final docs = doctors.where((d) => d.hospitalId == h.id).toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailHeader(title: h.name, image: h.image, heroTag: 'hospital-${h.id}'),
          SliverToBoxAdapter(
            child: MaxWidth(
              maxWidth: 840,
              child: Padding(
                padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.lg, context.pagePadding, Gap.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(h.name, style: context.text.headlineSmall),
                    const SizedBox(height: Gap.sm),
                    Wrap(
                      spacing: Gap.sm,
                      runSpacing: Gap.xs,
                      children: [
                        Pill(h.isGovt ? l.govt : l.privateLabel, color: h.isGovt ? p.info : p.primary),
                        if (h.emergency24)
                          Pill(l.emergencyAvailable, color: p.emergency, icon: Icons.emergency_rounded),
                        Pill(l.beds(context.digits(h.beds)), color: p.muted, icon: Icons.bed_outlined),
                        RatingLabel(h.rating),
                      ],
                    ),
                    const SizedBox(height: Gap.md),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 18, color: p.muted),
                        const SizedBox(width: Gap.xs),
                        Expanded(child: Text('${h.address}, ${upazilaName(h.upazila).of(context)}')),
                      ],
                    ),
                    const SizedBox(height: Gap.lg),
                    ContactActions(name: h.name, phone: h.phone),
                    DetailSection(
                      title: l.departments,
                      child: Wrap(
                        spacing: Gap.sm,
                        runSpacing: Gap.sm,
                        children: [for (final d in h.departments) Chip(label: Text(d))],
                      ),
                    ),
                    DetailSection(
                      title: l.facilities,
                      child: Wrap(
                        spacing: Gap.sm,
                        runSpacing: Gap.sm,
                        children: [
                          for (final f in h.facilities)
                            Chip(
                              avatar: Icon(Icons.check_circle_rounded, size: 16, color: p.success),
                              label: Text(f),
                            ),
                        ],
                      ),
                    ),
                    if (docs.isNotEmpty)
                      DetailSection(
                        title: l.doctorsHere,
                        child: Column(
                          children: [
                            for (final d in docs)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: AppAvatar(d.image, size: 44),
                                title: Text(d.name),
                                subtitle: Text(d.specialty),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () => context.push('/explore/doctors/${d.id}'),
                              ),
                          ],
                        ),
                      ),
                    DetailSection(
                      title: l.location,
                      child: MiniMap(pos: h.pos, title: h.name),
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
}

/// Collapsing image header with parallax, DEMO badge and back button.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.title,
    required this.image,
    this.heroTag,
    this.actions = const [],
    this.automaticallyImplyLeading = true,
  });
  final String title;
  final String image;
  final String? heroTag;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    final img = AppImage(image);
    return SliverAppBar(
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: automaticallyImplyLeading,
      expandedHeight: (MediaQuery.sizeOf(context).width * 0.56).clamp(180.0, 320.0),
      foregroundColor: Colors.white,
      backgroundColor: context.palette.primary,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
          const DemoBadge(onDark: true),
        ],
      ),
      actions: [
        ...actions,
        IconButton(
          tooltip: context.l10n.share,
          onPressed: () => context.toast(context.l10n.sharedDemo),
          icon: const Icon(Icons.share_rounded),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            heroTag == null ? img : Hero(tag: heroTag!, child: img),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, Colors.black26],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
