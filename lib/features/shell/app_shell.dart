import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/context_ext.dart';
import '../../l10n/app_localizations.dart';
import 'sos.dart';

class _Tab {
  const _Tab(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String Function(AppLocalizations) label;
}

final _tabs = <_Tab>[
  _Tab(Icons.home_outlined, Icons.home_rounded, (l) => l.navHome),
  _Tab(Icons.explore_outlined, Icons.explore_rounded, (l) => l.navExplore),
  _Tab(Icons.storefront_outlined, Icons.storefront_rounded, (l) => l.navShop),
  _Tab(Icons.bookmark_border_rounded, Icons.bookmark_rounded, (l) => l.navSaved),
  _Tab(Icons.person_outline_rounded, Icons.person_rounded, (l) => l.navProfile),
];

/// App shell: animated bottom nav on phones, NavigationRail on tablets,
/// floating SOS button everywhere.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell, required this.children});

  final StatefulNavigationShell shell;
  final List<Widget> children;

  void _go(int i) {
    HapticFeedback.selectionClick();
    shell.goBranch(i, initialLocation: i == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final tablet = context.isTablet;
    final body = FadeThroughIndexedStack(index: shell.currentIndex, children: children);
    if (tablet) {
      final l = context.l10n;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _go,
              labelType: NavigationRailLabelType.all,
              groupAlignment: -0.8,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: Gap.md),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: context.palette.headerGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_city_rounded, color: Colors.white),
                ),
              ),
              trailing: const Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: Gap.xl),
                    child: SosButton(mini: true),
                  ),
                ),
              ),
              destinations: [
                for (final t in _tabs)
                  NavigationRailDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.activeIcon),
                    label: Text(t.label(l)),
                  ),
              ],
            ),
            VerticalDivider(width: 1, color: context.palette.border),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      body: body,
      floatingActionButton: const SosButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AnimatedBottomNav(index: shell.currentIndex, onTap: _go),
    );
  }
}

/// Bottom nav where the selected tab expands into an icon + label pill.
class AnimatedBottomNav extends StatelessWidget {
  const AnimatedBottomNav({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
        boxShadow: p.isDark
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: Gap.sm),
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  flex: i == index ? 2 : 1,
                  child: _NavItem(tab: _tabs[i], label: _tabs[i].label(l), selected: i == index, onTap: () => onTap(i)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.label, required this.selected, required this.onTap});

  final _Tab tab;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Center(
          heightFactor: 1,
          child: AnimatedContainer(
            duration: Motion.medium,
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            padding: EdgeInsets.symmetric(horizontal: selected ? Gap.md : Gap.sm, vertical: Gap.sm),
            decoration: BoxDecoration(
              color: selected ? p.primarySoft : Colors.transparent,
              borderRadius: Radii.chipBorder,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: Motion.fast,
                  child: Icon(
                    selected ? tab.activeIcon : tab.icon,
                    key: ValueKey(selected),
                    color: selected ? p.primary : p.muted,
                    size: 24,
                  ),
                ),
                Flexible(
                  child: AnimatedSize(
                    duration: Motion.medium,
                    curve: Curves.easeOutCubic,
                    child: selected
                        ? Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: context.text.labelMedium?.copyWith(color: p.primary, fontWeight: FontWeight.w700),
                            ),
                          )
                        : const SizedBox.shrink(),
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

/// Keeps every tab alive (like IndexedStack) and fades-through into the
/// newly selected tab.
class FadeThroughIndexedStack extends StatefulWidget {
  const FadeThroughIndexedStack({super.key, required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<FadeThroughIndexedStack> createState() => _FadeThroughIndexedStackState();
}

class _FadeThroughIndexedStackState extends State<FadeThroughIndexedStack> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: Motion.medium, value: 1);

  @override
  void didUpdateWidget(FadeThroughIndexedStack old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          Offstage(
            offstage: i != widget.index,
            child: TickerMode(
              enabled: i == widget.index,
              child: i == widget.index
                  ? FadeThroughTransition(
                      animation: _c,
                      secondaryAnimation: kAlwaysDismissedAnimation,
                      fillColor: Colors.transparent,
                      child: widget.children[i],
                    )
                  : widget.children[i],
            ),
          ),
      ],
    );
  }
}
