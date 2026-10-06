import 'package:material_ui/material_ui.dart';

import '../../../data/demo/common_data.dart';
import '../../../data/demo/services_data.dart';
import '../../../data/models.dart';
import '../../../widgets/widgets.dart';
import '../module_scaffold.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tabs = [
      (l.school, InstitutionType.school, Icons.backpack_rounded),
      (l.college, InstitutionType.college, Icons.school_rounded),
      (l.university, InstitutionType.university, Icons.account_balance_rounded),
      (l.coaching, InstitutionType.coaching, Icons.menu_book_rounded),
    ];
    return DefaultTabController(
      length: tabs.length + 1,
      child: AppScaffold(
        title: l.education,
        bottom: TabBar(
          isScrollable: true,
          tabs: [
            for (final (label, _, icon) in tabs) Tab(icon: Icon(icon), text: label),
            Tab(icon: const Icon(Icons.fact_check_rounded), text: l.examResults),
          ],
        ),
        body: TabBarView(
          children: [
            for (final (_, type, icon) in tabs) _InstitutionList(type: type, icon: icon),
            const _ExamResults(),
          ],
        ),
      ),
    );
  }
}

class _InstitutionList extends StatelessWidget {
  const _InstitutionList({required this.type, required this.icon});
  final InstitutionType type;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final items = institutions.where((i) => i.type == type).toList();
    return DemoLoader(
      builder: (_) => ListView.separated(
        padding: listPadding(context),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
        itemBuilder: (_, i) {
          final x = items[i];
          final highlight = x.name.contains('MBSTU');
          return AppCard(
            padding: EdgeInsets.zero,
            border: highlight ? Border.all(color: p.primary, width: 1.5) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.card)),
                    child: AppImage(x.image),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Gap.md),
                  child: Row(
                    children: [
                      PastelIcon(icon, index: i),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(x.name, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Wrap(
                              spacing: Gap.sm,
                              runSpacing: 2,
                              children: [
                                Text(upazilaName(x.upazila).of(context), style: context.text.bodySmall),
                                Text(l.established(context.digits(x.established)), style: context.text.bodySmall),
                                Text(l.students(context.compact(x.students)), style: context.text.bodySmall),
                              ],
                            ),
                            const SizedBox(height: 2),
                            RatingLabel(x.rating),
                          ],
                        ),
                      ),
                      CallButton(name: x.name, number: x.phone),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExamResults extends StatelessWidget {
  const _ExamResults();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ListView.separated(
      padding: listPadding(context),
      itemCount: examResultLinks.length,
      separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
      itemBuilder: (_, i) {
        final (title, sub) = examResultLinks[i];
        return AppCard(
          onTap: () => context.toast(context.l10n.comingSoonDemo),
          child: Row(
            children: [
              PastelIcon(Icons.fact_check_rounded, index: i + 2),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleSmall),
                    Text(sub, style: context.text.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded, color: p.primary),
            ],
          ),
        );
      },
    );
  }
}
