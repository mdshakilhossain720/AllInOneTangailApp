import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/state/providers.dart';
import '../../../data/demo/common_data.dart';
import '../../../data/demo/health_data.dart';
import '../../../data/models.dart';
import '../../../widgets/widgets.dart';
import '../module_scaffold.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  String _specialty = 'all';
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = doctors
        .where(
          (d) => (_specialty == 'all' || d.specialty == _specialty) && d.name.toLowerCase().contains(_q.toLowerCase()),
        )
        .toList();
    return ModuleScaffold(
      title: l.doctors,
      header: Column(
        children: [
          ModuleSearch(hint: l.search, onChanged: (v) => setState(() => _q = v)),
          FilterChipBar(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            options: ['all', ...doctorSpecialties],
            selected: _specialty,
            labelOf: (o) => o == 'all' ? l.all : o,
            onSelected: (v) => setState(() => _specialty = v),
          ),
          const SizedBox(height: Gap.sm),
        ],
      ),
      list: (_) => items.isEmpty
          ? EmptyState(icon: Icons.medical_services_outlined, title: l.noResults, message: l.noResultsHint)
          : MasterDetail(
              key: ValueKey('$_specialty$_q'),
              initialId: items.first.id,
              routeFor: (id) => '/explore/doctors/$id',
              detail: (_, id) => DoctorDetailScreen(id: id, embedded: true),
              list: (context, select, selectedId) => ListView.separated(
                padding: listPadding(context),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
                itemBuilder: (_, i) =>
                    DoctorCard(doctor: items[i], selected: items[i].id == selectedId, onTap: () => select(items[i].id)),
              ),
            ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, this.onTap, this.selected = false});
  final Doctor doctor;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final d = doctor;
    return InfoCard(
      selected: selected,
      onTap: onTap ?? () => context.push('/explore/doctors/${d.id}'),
      leading: AppAvatar(d.image, size: 64, heroTag: selected ? null : 'doctor-${d.id}'),
      title: d.name,
      subtitle: '${d.specialty} · ${d.degrees}',
      meta: [(Icons.location_on_outlined, '${d.chamber}, ${upazilaName(d.upazila).of(context)}')],
      chips: [
        Pill(l.experienceYears(context.digits(d.experience)), color: p.info, dense: true),
        Pill('${l.fee} ${context.taka(d.fee)}', color: p.primary, dense: true),
        RatingLabel(d.rating),
      ],
      trailing: SaveButton(kind: SavedKind.doctors, id: d.id),
    );
  }
}

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.id, this.embedded = false});
  final String id;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final d = doctors.firstWhere((x) => x.id == id);
    final hospital = hospitals.firstWhere((h) => h.id == d.hospitalId);
    const days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final bnDays = {
      'Sat': 'শনি',
      'Sun': 'রবি',
      'Mon': 'সোম',
      'Tue': 'মঙ্গল',
      'Wed': 'বুধ',
      'Thu': 'বৃহঃ',
      'Fri': 'শুক্র',
    };
    final today = days[(DateTime.now().weekday + 1) % 7]; // weekday: Mon=1 … Sun=7

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(l.doctors)),
            const DemoBadge(),
          ],
        ),
        actions: [
          SaveButton(kind: SavedKind.doctors, id: d.id),
          IconButton(
            tooltip: l.share,
            onPressed: () => context.toast(l.sharedDemo),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      bottomNavigationBar: StickyBar(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.consultFee, style: context.text.bodySmall),
                  Text(context.taka(d.fee), style: context.text.titleLarge?.copyWith(color: p.primary)),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: CallButton(name: d.name, number: d.phone, label: l.serialCall, color: p.primary),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          MaxWidth(
            maxWidth: 840,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    children: [
                      AppAvatar(d.image, size: 96, heroTag: embedded ? null : 'doctor-${d.id}'),
                      const SizedBox(height: Gap.md),
                      Text(d.name, style: context.text.headlineSmall, textAlign: TextAlign.center),
                      Text(d.degrees, style: context.text.bodySmall, textAlign: TextAlign.center),
                      const SizedBox(height: Gap.sm),
                      Pill(d.specialty, color: p.primary),
                      const SizedBox(height: Gap.lg),
                      Row(
                        children: [
                          _Stat(value: context.digits('${d.experience}+'), label: l.experience),
                          _Stat(value: context.digits(d.rating.toStringAsFixed(1)), label: l.rating),
                          _Stat(value: context.taka(d.fee), label: l.fee),
                        ],
                      ),
                    ],
                  ),
                ),
                DetailSection(title: l.about, child: Text(d.about)),
                DetailSection(
                  title: l.weeklySchedule,
                  child: ClipRRect(
                    borderRadius: Radii.buttonBorder,
                    child: Table(
                      columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
                      children: [
                        for (final day in days)
                          TableRow(
                            decoration: BoxDecoration(
                              color: day == today
                                  ? p.primarySoft
                                  : (days.indexOf(day).isEven ? p.surfaceAlt : p.surface),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
                                child: Text(
                                  context.isBn ? bnDays[day]! : day,
                                  style: context.text.titleSmall?.copyWith(color: day == today ? p.primary : null),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
                                child: d.schedule[day] == null
                                    ? Text(l.closed, style: context.text.bodyMedium?.copyWith(color: p.emergency))
                                    : Text(context.digits(d.schedule[day]!), style: context.text.bodyMedium),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                DetailSection(
                  title: l.chamber,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.chamber, style: context.text.titleSmall),
                      Text(upazilaName(d.upazila).of(context), style: context.text.bodySmall),
                      const SizedBox(height: Gap.sm),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.local_hospital_outlined),
                        title: Text(hospital.name),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/explore/hospitals/${hospital.id}'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            child: Text(value, style: context.text.titleLarge?.copyWith(color: context.palette.primary)),
          ),
          Text(
            label,
            style: context.text.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
