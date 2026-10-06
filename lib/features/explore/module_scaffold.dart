import 'package:material_ui/material_ui.dart';

import '../../data/models.dart';
import '../../widgets/widgets.dart';

/// Shared chrome for Explore list screens: title + DEMO badge, optional
/// filters, optional list ⇄ map toggle, skeleton loading and pull-to-refresh.
class ModuleScaffold extends StatefulWidget {
  const ModuleScaffold({
    super.key,
    required this.title,
    required this.list,
    this.header,
    this.mapItems,
    this.onOpen,
    this.markerIcon = Icons.location_on_rounded,
    this.markerColor,
    this.floatingActionButton,
    this.actions = const [],
    this.skeleton = const LoadingShimmer.list(),
  });

  final String title;

  /// Builds the scrollable content (typically a ListView/MasterDetail).
  final WidgetBuilder list;

  /// Filters / search shown above the list (and the map).
  final Widget? header;
  final List<Mappable>? mapItems;
  final ValueChanged<String>? onOpen;
  final IconData markerIcon;
  final Color? markerColor;
  final Widget? floatingActionButton;
  final List<Widget> actions;
  final Widget skeleton;

  @override
  State<ModuleScaffold> createState() => _ModuleScaffoldState();
}

class _ModuleScaffoldState extends State<ModuleScaffold> {
  bool _map = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      maxWidth: false,
      floatingActionButton: widget.floatingActionButton,
      actions: [
        ...widget.actions,
        if (widget.mapItems != null) MapListToggle(showMap: _map, onChanged: (v) => setState(() => _map = v)),
      ],
      body: Column(
        children: [
          if (widget.header != null) MaxWidth(child: widget.header!),
          Expanded(
            child: AnimatedSwitcher(
              duration: Motion.medium,
              child: _map
                  ? DemoMap(
                      key: const ValueKey('map'),
                      items: widget.mapItems!,
                      onOpen: widget.onOpen,
                      markerIcon: widget.markerIcon,
                      markerColor: widget.markerColor,
                    )
                  : KeyedSubtree(
                      key: const ValueKey('list'),
                      child: AppRefresh(
                        child: DemoLoader(skeleton: widget.skeleton, builder: widget.list),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline search field used in module headers.
class ModuleSearch extends StatelessWidget {
  const ModuleSearch({super.key, required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.sm, context.pagePadding, Gap.sm),
      child: SearchBarWidget(hint: hint, onChanged: onChanged, elevated: false),
    );
  }
}

/// List padding that leaves room for FABs.
EdgeInsets listPadding(BuildContext context) =>
    EdgeInsets.fromLTRB(context.pagePadding, Gap.sm, context.pagePadding, 96);

/// Title row + content used inside detail screens.
class DetailSection extends StatelessWidget {
  const DetailSection({super.key, required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Gap.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: context.text.titleMedium)),
                if (trailing != null) Flexible(child: trailing!),
              ],
            ),
            const SizedBox(height: Gap.sm),
            child,
          ],
        ),
      ),
    );
  }
}

/// Call / SMS / Map actions for detail screens: icon-over-label tiles so
/// three fit side by side even on 320px screens with large text.
class ContactActions extends StatelessWidget {
  const ContactActions({super.key, required this.name, required this.phone, this.showSms = false});
  final String name;
  final String phone;
  final bool showSms;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final actions = [
      (Icons.call_rounded, l.call, p.success, () => confirmCall(context, name: name, number: phone)),
      if (showSms) (Icons.sms_outlined, l.sms, p.info, () => context.toast(l.smsDemo(context.digits(phone)))),
      (Icons.directions_outlined, l.directions, p.primary, () => context.toast(l.mapsDemo)),
    ];
    return Row(
      children: [
        for (final (i, (icon, label, color, onTap)) in actions.indexed) ...[
          if (i > 0) const SizedBox(width: Gap.sm),
          Expanded(
            child: Semantics(
              button: true,
              label: label,
              excludeSemantics: true,
              child: Material(
                color: color.withValues(alpha: p.isDark ? 0.2 : 0.1),
                borderRadius: Radii.buttonBorder,
                child: InkWell(
                  borderRadius: Radii.buttonBorder,
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Gap.md, horizontal: Gap.xs),
                    child: Column(
                      children: [
                        Icon(icon, color: color),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
