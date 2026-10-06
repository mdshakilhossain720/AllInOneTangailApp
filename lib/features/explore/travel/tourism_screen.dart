import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/state/providers.dart';
import '../../../data/demo/common_data.dart';
import '../../../data/models.dart';
import '../../../widgets/widgets.dart';
import '../health/hospitals_screen.dart' show DetailHeader;
import '../module_scaffold.dart';

class TourismScreen extends StatefulWidget {
  const TourismScreen({super.key});

  @override
  State<TourismScreen> createState() => _TourismScreenState();
}

class _TourismScreenState extends State<TourismScreen> {
  String _tag = 'all';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tags = {for (final p in places) p.tag}.toList();
    final items = places.where((p) => _tag == 'all' || p.tag == _tag).toList();
    return ModuleScaffold(
      title: l.tourism,
      mapItems: items,
      markerIcon: Icons.landscape_rounded,
      markerColor: context.palette.primary,
      onOpen: (id) => context.push('/explore/tourism/$id'),
      skeleton: const LoadingShimmer.grid(),
      header: Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.sm),
        child: FilterChipBar(
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
          options: ['all', ...tags],
          selected: _tag,
          labelOf: (o) => o == 'all' ? l.all : o,
          onSelected: (v) => setState(() => _tag = v),
        ),
      ),
      list: (_) => LayoutBuilder(
        builder: (context, c) {
          final cols = AppBreakpoints.value(c.maxWidth, compact: 2, phone: 2, largePhone: 3, tablet: 4);
          return SingleChildScrollView(
            padding: listPadding(context),
            child: MaxWidth(
              child: StaggeredGrid(
                columns: cols,
                children: [for (final p in items) PlaceTile(place: p)],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Masonry layout: each child goes into the currently shortest column.
/// Children size themselves (tiles use AspectRatio), so we balance by an
/// estimated height weight.
class StaggeredGrid extends StatelessWidget {
  const StaggeredGrid({super.key, required this.columns, required this.children, this.spacing = Gap.md});
  final int columns;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final cols = List.generate(columns, (_) => <Widget>[]);
    final heights = List.filled(columns, 0.0);
    for (final child in children) {
      final weight = child is PlaceTile && child.place.tall ? 1.4 : 1.0;
      var target = 0;
      for (var i = 1; i < columns; i++) {
        if (heights[i] < heights[target]) target = i;
      }
      cols[target].add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: child,
        ),
      );
      heights[target] += weight;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < columns; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: Column(children: cols[i])),
        ],
      ],
    );
  }
}

class PlaceTile extends StatelessWidget {
  const PlaceTile({super.key, required this.place});
  final Place place;

  @override
  Widget build(BuildContext context) {
    final pl = place;
    return Semantics(
      button: true,
      label: pl.name,
      excludeSemantics: true,
      child: PressableScale(
        onTap: () => context.push('/explore/tourism/${pl.id}'),
        child: ClipRRect(
          borderRadius: Radii.cardBorder,
          child: AspectRatio(
            aspectRatio: pl.tall ? 0.7 : 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(tag: 'place-${pl.id}', child: AppImage(pl.image)),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
                Positioned(
                  top: Gap.sm,
                  left: Gap.sm,
                  child: Pill(pl.tag, color: Colors.black54, solid: true, dense: true),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: SaveButton(kind: SavedKind.places, id: pl.id, color: Colors.white),
                ),
                Positioned(
                  left: Gap.md,
                  right: Gap.md,
                  bottom: Gap.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pl.name,
                        style: context.text.titleSmall?.copyWith(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.place_rounded, size: 12, color: Colors.white70),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              upazilaName(pl.upazila).of(context),
                              style: context.text.labelSmall?.copyWith(color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF5B301)),
                          Text(
                            context.digits(pl.rating),
                            style: context.text.labelSmall?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final pl = places.firstWhere((x) => x.id == id);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailHeader(
            title: pl.name,
            image: pl.image,
            heroTag: 'place-${pl.id}',
            actions: [SaveButton(kind: SavedKind.places, id: pl.id, color: Colors.white)],
          ),
          SliverToBoxAdapter(
            child: MaxWidth(
              maxWidth: 840,
              child: Padding(
                padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.lg, context.pagePadding, Gap.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(pl.name, style: context.text.headlineMedium),
                    const SizedBox(height: Gap.xs),
                    Wrap(
                      spacing: Gap.sm,
                      runSpacing: Gap.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Pill(pl.tag, color: p.info),
                        Pill(upazilaName(pl.upazila).of(context), color: p.muted, icon: Icons.place_rounded),
                        RatingStars(pl.rating),
                      ],
                    ),
                    const SizedBox(height: Gap.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.confirmation_number_outlined,
                            label: l.entryFee,
                            value: context.digits(pl.entryFee),
                          ),
                        ),
                        const SizedBox(width: Gap.md),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.schedule_rounded,
                            label: l.openingHours,
                            value: context.digits(pl.hours),
                          ),
                        ),
                      ],
                    ),
                    DetailSection(title: l.about, child: ReadMoreText(pl.about, maxLines: 4)),
                    DetailSection(
                      title: l.gallery,
                      child: SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: pl.gallery.length,
                          separatorBuilder: (_, _) => const SizedBox(width: Gap.sm),
                          itemBuilder: (_, i) => SizedBox(
                            width: 150,
                            child: ImageGallery(images: [pl.gallery[i]], aspectRatio: 150 / 110, radius: Radii.button),
                          ),
                        ),
                      ),
                    ),
                    DetailSection(
                      title: l.howToGo,
                      child: Column(
                        children: [
                          for (final (i, step) in pl.howToGo.indexed)
                            TimelineTile(
                              title: step,
                              isFirst: i == 0,
                              isLast: i == pl.howToGo.length - 1,
                              icon: i == 0 ? Icons.directions_bus_rounded : Icons.directions_walk_rounded,
                            ),
                        ],
                      ),
                    ),
                    DetailSection(
                      title: l.location,
                      child: MiniMap(pos: pl.pos, title: pl.name, height: 200),
                    ),
                    const SizedBox(height: Gap.lg),
                    PrimaryButton(
                      label: l.openInMaps,
                      icon: Icons.map_rounded,
                      onPressed: () => context.toast(l.mapsDemo),
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

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(color: p.primarySoft, borderRadius: Radii.cardBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: p.primary),
          const SizedBox(height: Gap.xs),
          Text(label, style: context.text.labelSmall?.copyWith(color: p.muted)),
          Text(value, style: context.text.titleSmall),
        ],
      ),
    );
  }
}
