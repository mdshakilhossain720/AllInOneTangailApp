import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../widgets/widgets.dart';
import '../explore/explore_modules.dart';

/// Every module, grouped by section, in a responsive grid (4 → 5 → 6 → 8).
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppScaffold(
      title: l.allCategories,
      body: LayoutBuilder(
        builder: (context, c) {
          final cols = AppBreakpoints.categoryColumns(c.maxWidth);
          return CustomScrollView(
            slivers: [
              for (final section in ModuleSection.values) ...[
                SliverToBoxAdapter(child: SectionHeader(sectionLabel(l, section))),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: context.pagePadding - 4),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisExtent: 52 + Gap.lg + 36 * context.textScale.clamp(1.0, 1.6),
                      mainAxisSpacing: Gap.sm,
                      crossAxisSpacing: Gap.xs,
                    ),
                    itemCount: exploreModules.where((m) => m.section == section).length,
                    itemBuilder: (context, i) {
                      final m = exploreModules.where((m) => m.section == section).elementAt(i);
                      return CategoryTile(
                        icon: m.icon,
                        label: m.label(l),
                        index: exploreModules.indexOf(m),
                        onTap: () => context.push(m.route),
                      );
                    },
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: Gap.xxl)),
            ],
          );
        },
      ),
    );
  }
}
