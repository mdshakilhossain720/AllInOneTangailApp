import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo/common_data.dart';
import '../../../data/demo/services_data.dart';
import '../../../data/models.dart';
import '../../../widgets/widgets.dart';
import '../module_scaffold.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  String _cat = 'all';
  String _type = 'all';
  String? _upazila;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = jobs
        .where(
          (j) =>
              (_cat == 'all' || j.category == _cat) &&
              (_type == 'all' || (_type == 'full') == j.fullTime) &&
              (_upazila == null || j.upazila == _upazila),
        )
        .toList();
    return ModuleScaffold(
      title: l.jobs,
      actions: [
        IconButton(
          tooltip: l.filter,
          onPressed: () => _filters(context),
          icon: Badge(
            isLabelVisible: _type != 'all' || _upazila != null,
            smallSize: 8,
            child: const Icon(Icons.tune_rounded),
          ),
        ),
      ],
      header: Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.sm),
        child: FilterChipBar(
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
          options: ['all', ...jobCategories],
          selected: _cat,
          labelOf: (o) => o == 'all' ? l.all : o,
          onSelected: (v) => setState(() => _cat = v),
        ),
      ),
      list: (_) => items.isEmpty
          ? EmptyState(icon: Icons.work_off_outlined, title: l.noResults, message: l.noResultsHint)
          : ListView.separated(
              padding: listPadding(context),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
              itemBuilder: (_, i) => JobCard(job: items[i], index: i),
            ),
    );
  }

  void _filters(BuildContext context) {
    final l = context.l10n;
    showAppSheet<void>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l.filter),
            Text(l.jobType, style: ctx.text.titleSmall),
            const SizedBox(height: Gap.sm),
            Wrap(
              spacing: Gap.sm,
              children: [
                for (final (v, label) in [('all', l.all), ('full', l.fullTime), ('part', l.partTime)])
                  ChoiceChip(
                    label: Text(label),
                    selected: _type == v,
                    onSelected: (_) {
                      setS(() {});
                      setState(() => _type = v);
                    },
                  ),
              ],
            ),
            const SizedBox(height: Gap.lg),
            DropdownButtonFormField<String?>(
              initialValue: _upazila,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.upazila, prefixIcon: const Icon(Icons.location_on_outlined)),
              items: [
                DropdownMenuItem(value: null, child: Text(l.allUpazilas)),
                for (final u in upazilas) DropdownMenuItem(value: u.name.en, child: Text(u.name.of(ctx))),
              ],
              onChanged: (v) => setState(() => _upazila = v),
            ),
            const SizedBox(height: Gap.xl),
            PrimaryButton(label: l.apply, onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, required this.index});
  final Job job;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final daysLeft = job.deadline.difference(DateTime.now()).inDays;
    return InfoCard(
      onTap: () => context.push('/explore/jobs/${job.id}'),
      leading: PastelIcon(Icons.business_center_rounded, index: index),
      title: job.title,
      subtitle: job.company,
      meta: [
        (Icons.payments_outlined, context.digits(job.salary)),
        (Icons.location_on_outlined, upazilaName(job.upazila).of(context)),
      ],
      chips: [
        Pill(job.fullTime ? l.fullTime : l.partTime, color: p.info, dense: true),
        Pill(job.category, color: p.muted, dense: true),
        Pill(
          l.deadline(context.shortDate(job.deadline)),
          color: daysLeft <= 5 ? p.emergency : p.success,
          icon: Icons.event_rounded,
          dense: true,
        ),
      ],
    );
  }
}

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final j = jobs.firstWhere((x) => x.id == id);
    return AppScaffold(
      title: l.jobs,
      actions: [
        IconButton(
          tooltip: l.share,
          onPressed: () => context.toast(l.sharedDemo),
          icon: const Icon(Icons.share_outlined),
        ),
      ],
      bottomBar: PrimaryButton(label: l.applyNow, icon: Icons.send_rounded, onPressed: () => _apply(context, j)),
      body: ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PastelIcon(Icons.business_center_rounded, index: 3, size: 56),
                const SizedBox(height: Gap.md),
                Text(j.title, style: context.text.headlineSmall),
                Text(j.company, style: context.text.titleSmall?.copyWith(color: p.muted)),
                const SizedBox(height: Gap.md),
                KeyValueRow(l.salary, context.digits(j.salary)),
                KeyValueRow(l.jobType, j.fullTime ? l.fullTime : l.partTime),
                KeyValueRow(l.location, upazilaName(j.upazila).of(context)),
                KeyValueRow(l.deadlineLabel, context.shortDate(j.deadline), valueColor: p.emergency),
              ],
            ),
          ),
          DetailSection(title: l.description, child: Text(j.description)),
          DetailSection(
            title: l.qualifications,
            child: Column(
              children: [
                for (final r in j.requirements)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Gap.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 18, color: p.success),
                        const SizedBox(width: Gap.sm),
                        Expanded(child: Text(r)),
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

  void _apply(BuildContext context, Job j) {
    final l = context.l10n;
    var attached = false;
    showAppSheet<void>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final p = ctx.palette;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitle(l.applyNow, subtitle: '${j.title} · ${j.company}'),
              const AppTextField(initialValue: 'Rahim Uddin', prefixIcon: Icons.person_outline_rounded),
              const AppTextField(
                initialValue: '01700000001',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              InkWell(
                borderRadius: Radii.buttonBorder,
                onTap: () => setS(() => attached = true),
                child: Container(
                  padding: const EdgeInsets.all(Gap.lg),
                  decoration: BoxDecoration(
                    color: attached ? p.primarySoft : p.surfaceAlt,
                    borderRadius: Radii.buttonBorder,
                    border: Border.all(color: attached ? p.primary : p.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        attached ? Icons.picture_as_pdf_rounded : Icons.upload_file_rounded,
                        color: attached ? p.emergency : p.muted,
                      ),
                      const SizedBox(width: Gap.md),
                      Expanded(child: Text(attached ? l.cvAttached : l.attachCv)),
                      if (attached) Icon(Icons.check_circle_rounded, color: p.success),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Gap.lg),
              AppTextField(label: l.coverNote, maxLines: 3),
              PrimaryButton(
                label: l.submit,
                onPressed: attached
                    ? () {
                        Navigator.pop(ctx);
                        context.toast(l.applicationSent(j.company));
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
