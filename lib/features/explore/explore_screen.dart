import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../widgets/widgets.dart';
import 'explore_modules.dart';

/// Explore tab: every local service grouped into sections.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return Scaffold(
      body: AppRefresh(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(l.exploreTitle, overflow: TextOverflow.ellipsis)),
                  const DemoBadge(),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: l.search,
                  onPressed: () => context.push('/search'),
                  icon: const Icon(Icons.search_rounded),
                ),
                const SizedBox(width: Gap.xs),
              ],
            ),
            SliverToBoxAdapter(
              child: MaxWidth(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(context.pagePadding, 0, context.pagePadding, Gap.sm),
                  child: Text(l.exploreSubtitle, style: context.text.bodyMedium?.copyWith(color: p.muted)),
                ),
              ),
            ),
            for (final section in ModuleSection.values) ...[
              SliverToBoxAdapter(child: MaxWidth(child: SectionHeader(sectionLabel(l, section)))),
              SliverToBoxAdapter(
                child: MaxWidth(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final items = exploreModules.where((m) => m.section == section).toList();
                      final cols = AppBreakpoints.value(c.maxWidth, compact: 2, phone: 2, largePhone: 3, tablet: 4);
                      final w = (c.maxWidth - 2 * context.pagePadding - (cols - 1) * Gap.md) / cols;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
                        child: Wrap(
                          spacing: Gap.md,
                          runSpacing: Gap.md,
                          children: [
                            for (final m in items)
                              SizedBox(
                                width: w,
                                child: Semantics(
                                  button: true,
                                  label: m.label(l),
                                  excludeSemantics: true,
                                  child: PressableScale(
                                    onTap: () => context.push(m.route),
                                    child: AppCard(
                                      padding: const EdgeInsets.all(Gap.md),
                                      child: Row(
                                        children: [
                                          PastelIcon(m.icon, index: exploreModules.indexOf(m), size: 44),
                                          const SizedBox(width: Gap.md),
                                          Expanded(
                                            child: Text(
                                              m.label(l),
                                              style: context.text.titleSmall,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
