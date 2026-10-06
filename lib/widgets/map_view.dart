import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme/tokens.dart';
import '../core/utils/context_ext.dart';
import '../core/utils/test_mode.dart';
import '../data/demo/common_data.dart';
import '../data/models.dart';

/// List ⇄ Map segmented toggle for app bars.
class MapListToggle extends StatelessWidget {
  const MapListToggle({super.key, required this.showMap, required this.onChanged});

  final bool showMap;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.xs),
      child: SegmentedButton<bool>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        segments: [
          ButtonSegment(value: false, icon: const Icon(Icons.view_list_rounded, size: 18), tooltip: context.l10n.list),
          ButtonSegment(value: true, icon: const Icon(Icons.map_rounded, size: 18), tooltip: context.l10n.map),
        ],
        selected: {showMap},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

/// OpenStreetMap view with demo markers. Tapping a marker shows a preview
/// card with a "View details" action.
class DemoMap extends StatefulWidget {
  const DemoMap({
    super.key,
    required this.items,
    this.onOpen,
    this.markerColor,
    this.markerIcon = Icons.location_on_rounded,
    this.interactive = true,
    this.zoom = 10.2,
  });

  final List<Mappable> items;
  final ValueChanged<String>? onOpen;
  final Color? markerColor;
  final IconData markerIcon;
  final bool interactive;
  final double zoom;

  @override
  State<DemoMap> createState() => _DemoMapState();
}

class _DemoMapState extends State<DemoMap> {
  Mappable? _selected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = widget.markerColor ?? p.emergency;
    final center = widget.items.length == 1 ? widget.items.first.pos : tangailCenter;
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: widget.items.length == 1 ? 14 : widget.zoom,
            interactionOptions: InteractionOptions(
              flags: widget.interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
            ),
            onTap: (_, _) => setState(() => _selected = null),
          ),
          children: [
            if (!UiTestMode.enabled)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.allinonetangail',
              ),
            MarkerLayer(
              markers: [
                for (final m in widget.items)
                  Marker(
                    point: m.pos,
                    width: 48,
                    height: 48,
                    alignment: Alignment.topCenter,
                    child: Semantics(
                      button: true,
                      label: m.mapTitle,
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = m),
                        child: AnimatedScale(
                          scale: _selected?.id == m.id ? 1.25 : 1,
                          duration: Motion.fast,
                          child: Icon(
                            widget.markerIcon,
                            color: color,
                            size: 40,
                            shadows: const [Shadow(blurRadius: 6, color: Colors.black38)],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
          ],
        ),
        if (_selected != null && widget.onOpen != null)
          Positioned(
            left: Gap.lg,
            right: Gap.lg,
            bottom: Gap.xl,
            child: SafeArea(
              top: false,
              child: Material(
                color: p.surface,
                elevation: 6,
                borderRadius: Radii.cardBorder,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.xs),
                  leading: Icon(widget.markerIcon, color: color),
                  title: Text(_selected!.mapTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: FilledButton(
                    onPressed: () => widget.onOpen!(_selected!.id),
                    child: Text(context.l10n.viewDetails),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Small non-interactive map preview for a single location.
class MiniMap extends StatelessWidget {
  const MiniMap({super.key, required this.pos, required this.title, this.height = 160});

  final LatLng pos;
  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: Radii.cardBorder,
      child: SizedBox(
        height: height,
        child: DemoMap(items: [_Point(pos, title)], interactive: false),
      ),
    );
  }
}

class _Point implements Mappable {
  _Point(this.pos, this.mapTitle);
  @override
  final LatLng pos;
  @override
  final String mapTitle;
  @override
  String get id => mapTitle;
}
