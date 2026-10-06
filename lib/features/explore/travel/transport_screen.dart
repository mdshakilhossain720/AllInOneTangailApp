import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo/common_data.dart';
import '../../../data/demo/services_data.dart';
import '../../../widgets/widgets.dart';
import '../module_scaffold.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: 3,
      child: AppScaffold(
        title: l.transport,
        bottom: TabBar(
          isScrollable: true,
          tabs: [
            Tab(icon: const Icon(Icons.directions_bus_rounded), text: l.busRoutes),
            Tab(icon: const Icon(Icons.train_rounded), text: l.train),
            Tab(icon: const Icon(Icons.local_taxi_rounded), text: l.cngRent),
          ],
        ),
        body: const TabBarView(children: [_BusTab(), _TrainTab(), _RentTab()]),
      ),
    );
  }
}

class _BusTab extends StatefulWidget {
  const _BusTab();

  @override
  State<_BusTab> createState() => _BusTabState();
}

class _BusTabState extends State<_BusTab> {
  String _from = 'Tangail';
  String _to = 'Dhaka (Mohakhali)';
  DateTime _date = DateTime.now();
  double _turns = 0;

  void _swap() => setState(() {
    final t = _from;
    _from = _to;
    _to = t;
    _turns += 0.5;
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    Widget stop(String label, String value, IconData icon, ValueChanged<String> onChanged) =>
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
          items: [
            for (final s in busStops)
              DropdownMenuItem(
                value: s,
                child: Text(s, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) => onChanged(v!),
        );
    return ListView(
      padding: EdgeInsets.all(context.pagePadding),
      children: [
        MaxWidth(
          maxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 56),
                              child: stop(l.from, _from, Icons.trip_origin_rounded, (v) => setState(() => _from = v)),
                            ),
                            const SizedBox(height: Gap.md),
                            Padding(
                              padding: const EdgeInsets.only(right: 56),
                              child: stop(l.to, _to, Icons.place_rounded, (v) => setState(() => _to = v)),
                            ),
                          ],
                        ),
                        AnimatedRotation(
                          turns: _turns,
                          duration: Motion.medium,
                          child: IconButton.filledTonal(
                            tooltip: '${l.from} ⇄ ${l.to}',
                            onPressed: _swap,
                            icon: const Icon(Icons.swap_vert_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Gap.md),
                    PickerField(
                      label: l.journeyDate,
                      icon: Icons.event_rounded,
                      value: context.shortDate(_date),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                          initialDate: _date,
                        );
                        if (d != null) setState(() => _date = d);
                      },
                    ),
                    PrimaryButton(
                      label: l.searchBuses,
                      icon: Icons.search_rounded,
                      onPressed: () => context.push(
                        '/explore/transport/buses?from=${Uri.encodeComponent(_from)}&to=${Uri.encodeComponent(_to)}&date=${_date.toIso8601String().substring(0, 10)}',
                      ),
                    ),
                  ],
                ),
              ),
              SectionHeader(
                l.popularRoutes,
                padding: const EdgeInsets.only(top: Gap.xl, bottom: Gap.sm),
              ),
              Wrap(
                spacing: Gap.sm,
                runSpacing: Gap.sm,
                children: [
                  for (final (a, b) in [
                    ('Tangail', 'Dhaka (Mohakhali)'),
                    ('Tangail', 'Mymensingh'),
                    ('Tangail', 'Sirajganj'),
                    ('Mirzapur', 'Gazipur'),
                    ('Madhupur', 'Tangail'),
                  ])
                    ActionChip(
                      avatar: Icon(Icons.route_rounded, size: 16, color: p.primary),
                      label: Text('$a → $b'),
                      onPressed: () => setState(() {
                        _from = a;
                        _to = b;
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BusResultsScreen extends StatelessWidget {
  const BusResultsScreen({super.key, required this.from, required this.to, required this.date});
  final String from;
  final String to;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final trips = busTripsFor(from, to);
    return AppScaffold(
      title: '$from → $to',
      body: DemoLoader(
        builder: (_) => ListView.separated(
          padding: listPadding(context),
          itemCount: trips.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
          itemBuilder: (_, i) {
            if (i == 0) {
              return Text(
                '${l.busesFound(context.digits(trips.length))} · ${context.shortDate(date)}',
                style: context.text.bodySmall,
              );
            }
            final t = trips[i - 1];
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.operator,
                          style: context.text.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Pill(
                        t.ac ? l.ac : l.nonAc,
                        color: t.ac ? p.info : p.muted,
                        icon: t.ac ? Icons.ac_unit_rounded : null,
                        dense: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.md),
                  Row(
                    children: [
                      _TimeCol(time: t.depart, label: l.departure),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: p.primary, shape: BoxShape.circle),
                              ),
                              Expanded(child: Divider(color: p.primary, thickness: 1.5)),
                              Icon(Icons.directions_bus_rounded, size: 18, color: p.primary),
                              Expanded(child: Divider(color: p.primary, thickness: 1.5)),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  border: Border.all(color: p.primary, width: 2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _TimeCol(time: t.arrive, label: l.arrival, end: true),
                    ],
                  ),
                  const SizedBox(height: Gap.md),
                  Row(
                    children: [
                      Icon(Icons.storefront_outlined, size: 14, color: p.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${l.counter}: ${t.counter}',
                          style: context.text.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: Gap.xl),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PriceText(t.fare),
                            Text(
                              l.seats(context.digits(t.seats)),
                              style: context.text.labelSmall?.copyWith(color: t.seats < 6 ? p.emergency : p.success),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(onPressed: () => _book(context, t.operator, t.fare), child: Text(l.bookSeat)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _book(BuildContext context, String operator, int fare) async {
    final l = context.l10n;
    var seats = 1;
    final ok = await showAppSheet<bool>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l.bookSeat, subtitle: operator),
            Row(
              children: [
                Expanded(child: Text(l.seatCount, style: ctx.text.titleSmall)),
                QuantityStepper(value: seats, max: 4, onChanged: (v) => setS(() => seats = v)),
              ],
            ),
            const SizedBox(height: Gap.lg),
            KeyValueRow(l.total, ctx.taka(fare * seats), bold: true),
            const SizedBox(height: Gap.lg),
            PrimaryButton(label: l.confirm, onPressed: () => Navigator.pop(ctx, true)),
          ],
        ),
      ),
    );
    if (ok == true && context.mounted) context.toast(l.comingSoonDemo);
  }
}

class _TimeCol extends StatelessWidget {
  const _TimeCol({required this.time, required this.label, this.end = false});
  final String time;
  final String label;
  final bool end;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 2,
      child: Column(
        crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(context.digits(time), style: context.text.titleMedium),
          ),
          Text(label, style: context.text.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _TrainTab extends StatelessWidget {
  const _TrainTab();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return ListView(
      padding: EdgeInsets.all(context.pagePadding),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(p.primarySoft),
              headingTextStyle: context.text.labelLarge?.copyWith(color: p.primary),
              columnSpacing: Gap.xl,
              columns: [
                DataColumn(label: Text(l.trainName)),
                DataColumn(label: Text(l.to)),
                DataColumn(label: Text(l.departure)),
                DataColumn(label: Text(l.arrival)),
                DataColumn(label: Text(l.offDay)),
                DataColumn(label: Text(l.fee), numeric: true),
              ],
              rows: [
                for (final t in trainSchedules)
                  DataRow(
                    cells: [
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name, style: context.text.titleSmall),
                            Text(context.digits('#${t.number}'), style: context.text.bodySmall),
                          ],
                        ),
                      ),
                      DataCell(Text(t.to)),
                      DataCell(Text(context.digits(t.depart))),
                      DataCell(Text(context.digits(t.arrive))),
                      DataCell(Pill(t.offDay, color: p.emergency, dense: true)),
                      DataCell(Text(context.taka(t.fare))),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Gap.md),
        Text(l.scheduleNote, style: context.text.bodySmall),
      ],
    );
  }
}

class _RentTab extends StatelessWidget {
  const _RentTab();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ListView.separated(
      padding: listPadding(context),
      itemCount: rentCars.length,
      separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
      itemBuilder: (_, i) {
        final r = rentCars[i];
        final icon = switch (r.type) {
          'CNG' => Icons.electric_rickshaw_rounded,
          'Microbus' => Icons.airport_shuttle_rounded,
          'Bike' => Icons.two_wheeler_rounded,
          _ => Icons.directions_car_rounded,
        };
        return InfoCard(
          leading: PastelIcon(icon, index: i),
          title: r.name,
          meta: [
            (Icons.payments_outlined, context.digits(r.rate)),
            (Icons.location_on_outlined, upazilaName(r.upazila).of(context)),
          ],
          chips: [
            Pill(r.type, color: p.info, dense: true),
            Pill(context.digits('${r.seats} 👤'), color: p.muted, dense: true),
            RatingLabel(r.rating),
          ],
          trailing: CallButton(name: r.name, number: r.phone),
        );
      },
    );
  }
}
