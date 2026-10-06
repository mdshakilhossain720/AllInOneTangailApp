import 'package:material_ui/material_ui.dart';

import '../../../data/demo/common_data.dart';
import '../../../data/demo/health_data.dart';
import '../../../data/models.dart';
import '../../../widgets/widgets.dart';
import '../module_scaffold.dart';

/// Ambulance list with AC / Non-AC / ICU and 24h badges.
class AmbulanceScreen extends StatefulWidget {
  const AmbulanceScreen({super.key});

  @override
  State<AmbulanceScreen> createState() => _AmbulanceScreenState();
}

class _AmbulanceScreenState extends State<AmbulanceScreen> {
  String _type = 'all';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final items = ambulances.where((a) => _type == 'all' || a.types.contains(_type)).toList();
    return ModuleScaffold(
      title: l.ambulance,
      header: Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.sm),
        child: FilterChipBar(
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
          options: const ['all', 'AC', 'Non-AC', 'ICU'],
          selected: _type,
          color: p.emergency,
          labelOf: (o) => switch (o) {
            'AC' => l.ac,
            'Non-AC' => l.nonAc,
            'ICU' => l.icu,
            _ => l.all,
          },
          onSelected: (v) => setState(() => _type = v),
        ),
      ),
      list: (_) => ListView.separated(
        padding: listPadding(context),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
        itemBuilder: (_, i) {
          final a = items[i];
          return InfoCard(
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: p.emergencySoft,
              child: Icon(Icons.airport_shuttle_rounded, color: p.emergency),
            ),
            title: a.provider,
            meta: [
              (Icons.location_on_outlined, upazilaName(a.upazila).of(context)),
              (Icons.payments_outlined, context.digits(a.rate)),
            ],
            chips: [
              for (final t in a.types)
                Pill(
                  switch (t) {
                    'AC' => l.ac,
                    'ICU' => l.icu,
                    _ => l.nonAc,
                  },
                  color: t == 'ICU' ? p.emergency : (t == 'AC' ? p.info : p.muted),
                  icon: t == 'ICU' ? Icons.monitor_heart_rounded : (t == 'AC' ? Icons.ac_unit_rounded : null),
                  dense: true,
                ),
              if (a.is24h) Pill(l.open24h, color: p.success, icon: Icons.schedule_rounded, dense: true),
            ],
            trailing: CallButton(name: a.provider, number: a.phone, color: p.emergency),
          );
        },
      ),
    );
  }
}

/// Police stations or fire stations, with map toggle.
class EmergencyServiceScreen extends StatelessWidget {
  const EmergencyServiceScreen({super.key, required this.kind});
  final ServiceKind kind;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final items = emergencyServices.where((e) => e.kind == kind).toList();
    final police = kind == ServiceKind.police;
    final icon = police ? Icons.local_police_rounded : Icons.local_fire_department_rounded;
    final color = police ? p.info : p.emergency;
    return ModuleScaffold(
      title: police ? l.police : l.fireService,
      mapItems: items,
      markerIcon: icon,
      markerColor: color,
      onOpen: (id) {
        final e = items.firstWhere((x) => x.id == id);
        confirmCall(context, name: e.name, number: e.phone);
      },
      header: Padding(
        padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.sm, context.pagePadding, Gap.sm),
        child: AppCard(
          color: p.emergencySoft,
          border: Border.all(color: p.emergency.withValues(alpha: 0.4)),
          onTap: () => confirmCall(context, name: l.nationalEmergency, number: '999'),
          padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
          child: Row(
            children: [
              Icon(Icons.local_phone_rounded, color: p.emergency),
              const SizedBox(width: Gap.md),
              Expanded(child: Text(l.nationalEmergency, style: context.text.titleSmall)),
              Text(
                context.digits('999'),
                style: context.text.headlineSmall?.copyWith(color: p.emergency, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
      list: (_) => ListView.separated(
        padding: listPadding(context),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
        itemBuilder: (_, i) {
          final e = items[i];
          return InfoCard(
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            title: e.name,
            meta: [
              (Icons.location_on_outlined, '${e.address} · ${upazilaName(e.upazila).of(context)}'),
              (Icons.phone_outlined, context.digits(e.phone)),
            ],
            chips: [Pill(l.open24h, color: p.success, icon: Icons.schedule_rounded, dense: true)],
            trailing: CallButton(name: e.name, number: e.phone, color: color),
          );
        },
      ),
    );
  }
}

/// Government offices grouped by upazila.
class GovtOfficesScreen extends StatelessWidget {
  const GovtOfficesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final groups = <String, List<GovtOffice>>{};
    for (final g in govtOffices) {
      groups.putIfAbsent(g.upazila, () => []).add(g);
    }
    return ModuleScaffold(
      title: l.govtOffices,
      list: (_) => ListView(
        padding: listPadding(context),
        children: [
          for (final e in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: Gap.md, bottom: Gap.sm),
              child: Row(
                children: [
                  Icon(Icons.location_city_rounded, size: 18, color: context.palette.primary),
                  const SizedBox(width: Gap.sm),
                  Text(upazilaName(e.key).of(context), style: context.text.titleMedium),
                  const SizedBox(width: Gap.sm),
                  Pill(context.digits(e.value.length), color: context.palette.muted, dense: true),
                ],
              ),
            ),
            for (final (i, g) in e.value.indexed) ...[
              InfoCard(
                leading: PastelIcon(g.icon, index: i + 3),
                title: g.name,
                meta: [(Icons.place_outlined, g.address), (Icons.schedule_rounded, g.hours)],
                trailing: CallButton(name: g.name, number: g.phone),
              ),
              const SizedBox(height: Gap.sm),
            ],
          ],
        ],
      ),
    );
  }
}
