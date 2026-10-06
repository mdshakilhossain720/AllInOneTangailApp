import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo/common_data.dart';
import '../../../data/demo/services_data.dart';
import '../../../widgets/widgets.dart';
import '../module_scaffold.dart';
import 'event_sheet.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab.clamp(0, 2),
      child: AppScaffold(
        title: l.community,
        bottom: TabBar(
          isScrollable: true,
          tabs: [
            Tab(icon: const Icon(Icons.campaign_rounded), text: l.noticeBoard),
            Tab(icon: const Icon(Icons.travel_explore_rounded), text: l.lostFound),
            Tab(icon: const Icon(Icons.calendar_month_rounded), text: l.eventsCalendar),
          ],
        ),
        body: const TabBarView(children: [_NoticeBoard(), _LostFound(), _EventsCalendar()]),
      ),
    );
  }
}

class _NoticeBoard extends StatelessWidget {
  const _NoticeBoard();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppRefresh(
      child: DemoLoader(
        builder: (_) => ListView.separated(
          padding: listPadding(context),
          itemCount: notices.length,
          separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
          itemBuilder: (_, i) {
            final n = notices[i];
            return AppCard(
              border: n.important ? Border(left: BorderSide(color: p.emergency, width: 4)) : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (n.important) ...[
                        Pill(context.l10n.urgent, color: p.emergency, icon: Icons.priority_high_rounded, dense: true),
                        const SizedBox(width: Gap.sm),
                      ],
                      Expanded(
                        child: Text(
                          n.issuer,
                          style: context.text.labelMedium?.copyWith(color: p.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        n.daysAgo == 0 ? context.l10n.today : context.l10n.daysShort(context.digits(n.daysAgo)),
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.sm),
                  Text(n.title, style: context.text.titleSmall),
                  const SizedBox(height: Gap.xs),
                  Text(n.body, style: context.text.bodyMedium?.copyWith(color: p.muted)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LostFound extends StatefulWidget {
  const _LostFound();

  @override
  State<_LostFound> createState() => _LostFoundState();
}

class _LostFoundState extends State<_LostFound> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final items = lostFoundItems.where((x) => _filter == 'all' || (_filter == 'lost') == x.isLost).toList();
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Gap.sm),
              child: FilterChipBar(
                padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
                options: const ['all', 'lost', 'found'],
                selected: _filter,
                labelOf: (o) => switch (o) {
                  'lost' => l.lost,
                  'found' => l.found,
                  _ => l.all,
                },
                onSelected: (v) => setState(() => _filter = v),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final cols = AppBreakpoints.value(c.maxWidth, compact: 1, phone: 1, largePhone: 2, tablet: 3);
                  return GridView.builder(
                    padding: listPadding(context),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: Gap.md,
                      crossAxisSpacing: Gap.md,
                      mainAxisExtent: 120 + 40 * context.textScale.clamp(1.0, 1.6),
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final x = items[i];
                      return AppCard(
                        padding: const EdgeInsets.all(Gap.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              child: AspectRatio(aspectRatio: 1, child: AppImage(x.image, radius: Radii.button)),
                            ),
                            const SizedBox(width: Gap.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Pill(
                                    x.isLost ? l.lost : l.found,
                                    color: x.isLost ? p.emergency : p.success,
                                    solid: true,
                                    dense: true,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    x.title,
                                    style: context.text.titleSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    x.description,
                                    style: context.text.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Icon(Icons.place_outlined, size: 13, color: p.muted),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          x.location,
                                          style: context.text.labelSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 36,
                                        width: 36,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          tooltip: l.call,
                                          onPressed: () => confirmCall(context, name: x.title, number: x.phone),
                                          icon: Icon(Icons.call_rounded, size: 18, color: p.success),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: Gap.lg,
          bottom: Gap.lg,
          child: SafeArea(
            child: FloatingActionButton.extended(
              heroTag: 'lost-found-post',
              onPressed: () => context.push('/explore/community/post'),
              icon: const Icon(Icons.add_a_photo_rounded),
              label: Text(l.postItem),
            ),
          ),
        ),
      ],
    );
  }
}

class PostLostFoundScreen extends StatefulWidget {
  const PostLostFoundScreen({super.key});

  @override
  State<PostLostFoundScreen> createState() => _PostLostFoundScreenState();
}

class _PostLostFoundScreenState extends State<PostLostFoundScreen> {
  final _form = GlobalKey<FormState>();
  bool _lost = true;
  String _upazila = upazilas.first.name.en;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    String? req(String? v) => (v == null || v.trim().isEmpty) ? l.required : null;
    return AppScaffold(
      title: l.postItem,
      bottomBar: PrimaryButton(
        label: l.submit,
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          context.toast(l.postPublished);
          context.pop();
        },
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  label: Text(l.lost),
                  icon: Icon(Icons.search_rounded, color: _lost ? p.emergency : null),
                ),
                ButtonSegment(
                  value: false,
                  label: Text(l.found),
                  icon: Icon(Icons.volunteer_activism_rounded, color: !_lost ? p.success : null),
                ),
              ],
              selected: {_lost},
              onSelectionChanged: (s) => setState(() => _lost = s.first),
            ),
            const SizedBox(height: Gap.lg),
            Text(l.addPhoto, style: context.text.titleSmall),
            const SizedBox(height: Gap.sm),
            const PhotoPickerGrid(max: 3, seed: 'lostfound'),
            const SizedBox(height: Gap.lg),
            AppTextField(label: l.title, validator: req),
            AppTextField(label: l.description, maxLines: 3),
            DropdownButtonFormField<String>(
              initialValue: _upazila,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.upazila, prefixIcon: const Icon(Icons.location_on_outlined)),
              items: [for (final u in upazilas) DropdownMenuItem(value: u.name.en, child: Text(u.name.of(context)))],
              onChanged: (v) => setState(() => _upazila = v!),
            ),
            const SizedBox(height: Gap.lg),
            AppTextField(label: l.location, prefixIcon: Icons.place_outlined, validator: req),
            AppTextField(
              label: l.mobileNumber,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              initialValue: '01700000001',
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsCalendar extends StatefulWidget {
  const _EventsCalendar();

  @override
  State<_EventsCalendar> createState() => _EventsCalendarState();
}

class _EventsCalendarState extends State<_EventsCalendar> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _selected = localEvents.first.date;

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final locale = context.isBn ? 'bn' : 'en';
    final first = DateTime(_month.year, _month.month);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = first.weekday % 7; // Sunday-first grid
    final dayEvents = localEvents.where((e) => _sameDay(e.date, _selected)).toList();
    final weekdayNames = [for (var i = 0; i < 7; i++) DateFormat('E', locale).format(DateTime(2026, 10, 4 + i))];

    return ListView(
      padding: listPadding(context),
      children: [
        MaxWidth(
          maxWidth: 640,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                padding: const EdgeInsets.all(Gap.md),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: l.back,
                          onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(
                          child: Text(
                            context.digits(DateFormat('MMMM yyyy', locale).format(_month)),
                            textAlign: TextAlign.center,
                            style: context.text.titleMedium,
                          ),
                        ),
                        IconButton(
                          tooltip: l.next,
                          onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: Gap.sm),
                    Row(
                      children: [
                        for (final w in weekdayNames)
                          Expanded(
                            child: Text(
                              w,
                              textAlign: TextAlign.center,
                              style: context.text.labelSmall?.copyWith(color: p.muted),
                              maxLines: 1,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: Gap.xs),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                      itemCount: leading + daysInMonth,
                      itemBuilder: (_, i) {
                        if (i < leading) return const SizedBox.shrink();
                        final day = DateTime(_month.year, _month.month, i - leading + 1);
                        final has = localEvents.any((e) => _sameDay(e.date, day));
                        final sel = _sameDay(day, _selected);
                        final today = _sameDay(day, DateTime.now());
                        return Semantics(
                          button: true,
                          selected: sel,
                          label: DateFormat.yMMMd(locale).format(day),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => setState(() => _selected = day),
                            child: AnimatedContainer(
                              duration: Motion.fast,
                              margin: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: sel ? p.primary : (today ? p.primarySoft : null),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    context.digits(day.day),
                                    style: context.text.labelLarge?.copyWith(color: sel ? Colors.white : p.text),
                                  ),
                                  if (has)
                                    Positioned(
                                      bottom: 4,
                                      child: Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: sel ? Colors.white : p.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Gap.lg),
              Text(
                context.digits(DateFormat('EEEE, d MMMM', locale).format(_selected)),
                style: context.text.titleMedium,
              ),
              const SizedBox(height: Gap.sm),
              if (dayEvents.isEmpty)
                AppCard(
                  child: Row(
                    children: [
                      Icon(Icons.event_busy_rounded, color: p.muted),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: Text(l.noEventsDay, style: context.text.bodyMedium?.copyWith(color: p.muted)),
                      ),
                    ],
                  ),
                ),
              for (final e in dayEvents)
                InfoCard(
                  onTap: () => showEventSheet(context, e),
                  leading: SizedBox.square(dimension: 64, child: AppImage(e.image, radius: Radii.button)),
                  title: e.title,
                  meta: [(Icons.place_outlined, e.place)],
                  chips: [Pill(e.category, color: p.info, dense: true)],
                ),
              const SizedBox(height: Gap.lg),
              Text(l.upcomingEvents, style: context.text.titleMedium),
              const SizedBox(height: Gap.sm),
              for (final e in localEvents) ...[
                InfoCard(
                  onTap: () => setState(() {
                    _month = DateTime(e.date.year, e.date.month);
                    _selected = e.date;
                  }),
                  leading: Container(
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: Gap.sm),
                    decoration: BoxDecoration(color: p.primarySoft, borderRadius: Radii.buttonBorder),
                    child: Column(
                      children: [
                        Text(context.digits(e.date.day), style: context.text.titleLarge?.copyWith(color: p.primary)),
                        Text(DateFormat('MMM', locale).format(e.date), style: context.text.labelSmall),
                      ],
                    ),
                  ),
                  title: e.title,
                  meta: [(Icons.place_outlined, e.place)],
                ),
                const SizedBox(height: Gap.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
