import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/state/providers.dart';
import '../../../data/demo/services_data.dart';
import '../../../data/models.dart';
import '../../../widgets/widgets.dart';
import '../module_scaffold.dart';

String practiceAreaLabel(BuildContext context, String area) {
  if (!context.isBn) return area;
  return const {
        'Criminal': 'ফৌজদারি',
        'Civil': 'দেওয়ানি',
        'Family': 'পারিবারিক',
        'Land': 'জমিজমা',
        'Company': 'কোম্পানি',
        'Tax': 'কর',
      }[area] ??
      area;
}

class LawyersScreen extends StatefulWidget {
  const LawyersScreen({super.key});

  @override
  State<LawyersScreen> createState() => _LawyersScreenState();
}

class _LawyersScreenState extends State<LawyersScreen> {
  String _area = 'all';
  String? _court;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = lawyers
        .where((x) => (_area == 'all' || x.areas.contains(_area)) && (_court == null || x.court == _court))
        .toList();
    return ModuleScaffold(
      title: l.lawyers,
      header: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.sm, context.pagePadding, Gap.sm),
            child: DropdownButtonFormField<String?>(
              initialValue: _court,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l.court,
                prefixIcon: const Icon(Icons.account_balance_outlined),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(l.all)),
                for (final c in courts)
                  DropdownMenuItem(
                    value: c,
                    child: Text(c, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _court = v),
            ),
          ),
          FilterChipBar(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            options: ['all', ...practiceAreas],
            selected: _area,
            labelOf: (o) => o == 'all' ? l.all : practiceAreaLabel(context, o),
            onSelected: (v) => setState(() => _area = v),
          ),
          const SizedBox(height: Gap.sm),
        ],
      ),
      list: (_) => items.isEmpty
          ? EmptyState(icon: Icons.gavel_rounded, title: l.noResults, message: l.noResultsHint)
          : MasterDetail(
              key: ValueKey('$_area$_court'),
              initialId: items.first.id,
              routeFor: (id) => '/explore/lawyers/$id',
              detail: (_, id) => LawyerDetailScreen(id: id, embedded: true),
              list: (context, select, selectedId) => ListView.separated(
                padding: listPadding(context),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
                itemBuilder: (_, i) =>
                    LawyerCard(lawyer: items[i], selected: selectedId == items[i].id, onTap: () => select(items[i].id)),
              ),
            ),
    );
  }
}

class LawyerCard extends StatelessWidget {
  const LawyerCard({super.key, required this.lawyer, this.onTap, this.selected = false});
  final Lawyer lawyer;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final x = lawyer;
    return InfoCard(
      selected: selected,
      onTap: onTap,
      leading: AppAvatar(x.image, size: 64, heroTag: selected ? null : 'lawyer-${x.id}'),
      title: x.name,
      subtitle: x.court,
      meta: [(Icons.work_history_outlined, l.experienceYears(context.digits(x.experience)))],
      chips: [
        for (final a in x.areas) Pill(practiceAreaLabel(context, a), color: p.info, dense: true),
        RatingLabel(x.rating),
      ],
      trailing: Column(
        children: [
          CallButton(name: x.name, number: x.phone),
          SaveButton(kind: SavedKind.lawyers, id: x.id),
        ],
      ),
    );
  }
}

class LawyerDetailScreen extends StatelessWidget {
  const LawyerDetailScreen({super.key, required this.id, this.embedded = false});
  final String id;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final x = lawyers.firstWhere((e) => e.id == id);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(l.lawyers)),
            const DemoBadge(),
          ],
        ),
        actions: [SaveButton(kind: SavedKind.lawyers, id: x.id)],
      ),
      bottomNavigationBar: StickyBar(
        child: PrimaryButton(
          label: l.bookConsultation,
          icon: Icons.event_available_rounded,
          onPressed: () => showBookingSheet(context, x),
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
                      Row(
                        children: [
                          AppAvatar(x.image, size: 84, heroTag: embedded ? null : 'lawyer-${x.id}'),
                          const SizedBox(width: Gap.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(x.name, style: context.text.titleLarge),
                                Text(x.court, style: context.text.bodySmall),
                                const SizedBox(height: Gap.xs),
                                RatingStars(x.rating, count: x.cases ~/ 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Gap.lg),
                      Row(
                        children: [
                          _Fact(Icons.work_history_outlined, context.digits('${x.experience}+'), l.experience),
                          _Fact(Icons.folder_copy_outlined, context.compact(x.cases), l.cases),
                          _Fact(Icons.payments_outlined, context.taka(x.fee), l.fee),
                        ],
                      ),
                      const SizedBox(height: Gap.lg),
                      ContactActions(name: x.name, phone: x.phone, showSms: true),
                    ],
                  ),
                ),
                DetailSection(
                  title: l.practiceArea,
                  child: Wrap(
                    spacing: Gap.sm,
                    runSpacing: Gap.sm,
                    children: [for (final a in x.areas) Chip(label: Text(practiceAreaLabel(context, a)))],
                  ),
                ),
                DetailSection(title: l.about, child: ReadMoreText(x.bio)),
                DetailSection(
                  title: l.education,
                  child: Column(
                    children: [
                      for (final e in x.education)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: p.primarySoft,
                            child: Icon(Icons.school_outlined, color: p.primary, size: 20),
                          ),
                          title: Text(e, style: context.text.bodyMedium),
                        ),
                    ],
                  ),
                ),
                DetailSection(
                  title: l.chamberHours,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 18, color: p.muted),
                          const SizedBox(width: Gap.sm),
                          Expanded(child: Text(x.chamberHours)),
                        ],
                      ),
                      const SizedBox(height: Gap.xs),
                      Row(
                        children: [
                          Icon(Icons.place_outlined, size: 18, color: p.muted),
                          const SizedBox(width: Gap.sm),
                          Expanded(child: Text(x.chamber)),
                        ],
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

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.value, this.label);
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: context.palette.primary),
          const SizedBox(height: 2),
          FittedBox(child: Text(value, style: context.text.titleMedium)),
          Text(label, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Date strip + time-slot grid booking sheet (UI only).
Future<void> showBookingSheet(BuildContext context, Lawyer lawyer) {
  return showAppSheet<void>(context, builder: (_) => _BookingSheet(lawyer: lawyer));
}

class _BookingSheet extends StatefulWidget {
  const _BookingSheet({required this.lawyer});
  final Lawyer lawyer;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  late final _days = [for (var i = 0; i < 7; i++) DateTime.now().add(Duration(days: i + 1))];
  int _day = 0;
  String? _slot;
  static const _slots = ['5:00 PM', '5:30 PM', '6:00 PM', '6:30 PM', '7:00 PM', '7:30 PM', '8:00 PM', '8:30 PM'];
  static const _booked = {'6:00 PM', '7:30 PM'};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final locale = context.isBn ? 'bn' : 'en';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l.bookConsultation, subtitle: '${widget.lawyer.name} · ${context.taka(widget.lawyer.fee)}'),
        Text(l.pickDate, style: context.text.titleSmall),
        const SizedBox(height: Gap.sm),
        SizedBox(
          height: 76 * context.textScale.clamp(1.0, 1.4),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            separatorBuilder: (_, _) => const SizedBox(width: Gap.sm),
            itemBuilder: (_, i) {
              final d = _days[i];
              final sel = i == _day;
              return Semantics(
                selected: sel,
                button: true,
                child: InkWell(
                  borderRadius: Radii.buttonBorder,
                  onTap: () => setState(() {
                    _day = i;
                    _slot = null;
                  }),
                  child: AnimatedContainer(
                    duration: Motion.fast,
                    width: 60,
                    decoration: BoxDecoration(
                      color: sel ? p.primary : p.surface,
                      borderRadius: Radii.buttonBorder,
                      border: Border.all(color: sel ? p.primary : p.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE', locale).format(d),
                          style: context.text.labelSmall?.copyWith(color: sel ? Colors.white70 : p.muted),
                        ),
                        Text(
                          context.digits(d.day),
                          style: context.text.titleLarge?.copyWith(color: sel ? Colors.white : p.text),
                        ),
                        Text(
                          DateFormat('MMM', locale).format(d),
                          style: context.text.labelSmall?.copyWith(color: sel ? Colors.white70 : p.muted),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Gap.lg),
        Text(l.pickTime, style: context.text.titleSmall),
        const SizedBox(height: Gap.sm),
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            for (final s in _slots)
              ChoiceChip(
                label: Text(context.digits(s)),
                selected: _slot == s,
                onSelected: _booked.contains(s) ? null : (_) => setState(() => _slot = s),
                selectedColor: p.primary,
                labelStyle: TextStyle(
                  color: _slot == s ? Colors.white : (_booked.contains(s) ? p.muted : p.text),
                  decoration: _booked.contains(s) ? TextDecoration.lineThrough : null,
                ),
              ),
          ],
        ),
        const SizedBox(height: Gap.lg),
        AppTextField(label: l.describeMatter, maxLines: 2),
        PrimaryButton(
          label: l.confirm,
          onPressed: _slot == null
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  context.toast(l.consultationBooked('${context.shortDate(_days[_day])}, ${context.digits(_slot!)}'));
                },
        ),
      ],
    );
  }
}
