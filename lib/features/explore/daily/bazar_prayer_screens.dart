import 'dart:math';

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo/services_data.dart';
import '../../../data/models.dart';
import '../../../widgets/widgets.dart';
import '../../home/home_screen.dart' show ChangeIndicator, prayerName;

/// Bazar price table with ▲/▼ % change and a 7-day line chart for the
/// selected item.
class BazarScreen extends StatefulWidget {
  const BazarScreen({super.key});

  @override
  State<BazarScreen> createState() => _BazarScreenState();
}

class _BazarScreenState extends State<BazarScreen> {
  BazarItem _selected = bazarItems[1];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final days = [for (var i = 6; i >= 0; i--) DateTime.now().subtract(Duration(days: i))];
    final chart = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_selected.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selected.name.of(context), style: context.text.titleMedium),
                    Text(l.last7Days, style: context.text.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${context.taka(_selected.price)}/${_selected.unit.of(context)}',
                    style: context.text.titleMedium,
                  ),
                  ChangeIndicator(pct: _selected.changePct),
                ],
              ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          TrendLineChart(
            values: _selected.history,
            labels: [for (final d in days) context.digits(DateFormat('d/M').format(d))],
            color: _selected.changePct > 0 ? p.emergency : p.success,
            valueFormatter: (v) => context.taka(v),
          ),
        ],
      ),
    );

    final table = AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
            decoration: BoxDecoration(
              color: p.primarySoft,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.card)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(l.item, style: context.text.labelLarge?.copyWith(color: p.primary)),
                ),
                Text(l.price, style: context.text.labelLarge?.copyWith(color: p.primary)),
                const SizedBox(width: Gap.md),
                SizedBox(
                  width: 64,
                  child: Text(
                    l.change,
                    textAlign: TextAlign.center,
                    style: context.text.labelLarge?.copyWith(color: p.primary),
                  ),
                ),
              ],
            ),
          ),
          for (final item in bazarItems)
            Material(
              color: item == _selected ? p.surfaceAlt : Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selected = item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
                  child: BazarRowSelectable(item: item, selected: item == _selected),
                ),
              ),
            ),
        ],
      ),
    );

    return AppScaffold(
      title: l.bazarPrice,
      body: AppRefresh(
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 900;
            return ListView(
              padding: EdgeInsets.all(context.pagePadding),
              children: [
                Text('${context.shortDate(DateTime.now())} · ${l.bazarSource}', style: context.text.bodySmall),
                const SizedBox(height: Gap.md),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: table),
                      const SizedBox(width: Gap.lg),
                      Expanded(child: chart),
                    ],
                  )
                else ...[
                  chart,
                  const SizedBox(height: Gap.md),
                  table,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class BazarRowSelectable extends StatelessWidget {
  const BazarRowSelectable({super.key, required this.item, required this.selected});
  final BazarItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.md),
        child: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.of(context),
                    style: context.text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('/${item.unit.of(context)}', style: context.text.bodySmall),
                ],
              ),
            ),
            Text(context.taka(item.price), style: context.text.titleSmall),
            const SizedBox(width: Gap.md),
            ChangeIndicator(pct: item.changePct),
          ],
        ),
      ),
    );
  }
}

/// Five daily prayers with the next one highlighted, sehri/iftar and a
/// circular countdown to the next waqt.
class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final now = DateTime.now();
    final list = prayersFor(now);
    final next = nextPrayer(now);
    final prev =
        list.where((x) => x.key != 'sunrise' && !x.time.isAfter(now)).lastOrNull?.time ??
        prayersFor(now.subtract(const Duration(days: 1))).last.time;
    final icons = {
      'fajr': Icons.nights_stay_rounded,
      'sunrise': Icons.wb_twilight_rounded,
      'dhuhr': Icons.wb_sunny_rounded,
      'asr': Icons.light_mode_rounded,
      'maghrib': Icons.wb_twilight_rounded,
      'isha': Icons.dark_mode_rounded,
    };

    return AppScaffold(
      title: l.prayerTimes,
      body: ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          MaxWidth(
            maxWidth: 640,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(Gap.xl),
                  decoration: BoxDecoration(gradient: p.headerGradient, borderRadius: Radii.cardBorder),
                  child: Column(
                    children: [
                      Text(
                        '${context.digits(DateFormat('EEEE, d MMMM', context.isBn ? 'bn' : 'en').format(now))} · ${l.weatherTangail}',
                        style: context.text.bodySmall?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Gap.lg),
                      CountdownBuilder(
                        target: next.time,
                        builder: (context, left) {
                          final total = next.time.difference(prev).inSeconds.clamp(1, 1 << 30);
                          final progress = 1 - left.inSeconds / total;
                          return SizedBox.square(
                            dimension: 200,
                            child: CustomPaint(
                              painter: _RingPainter(progress: progress, color: const Color(0xFFFFD58A)),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(icons[next.key], color: Colors.white),
                                    Text(
                                      prayerName(l, next.key),
                                      style: context.text.titleLarge?.copyWith(color: Colors.white),
                                    ),
                                    Text(
                                      formatRemaining(context, left),
                                      style: context.text.titleMedium?.copyWith(
                                        color: const Color(0xFFFFD58A),
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                    Text(l.startsIn, style: context.text.labelSmall?.copyWith(color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: Gap.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _SehriIftar(
                              icon: Icons.nights_stay_outlined,
                              label: l.sehri,
                              time: context.clock(list.first.time.subtract(const Duration(minutes: 10))),
                            ),
                          ),
                          const SizedBox(width: Gap.md),
                          Expanded(
                            child: _SehriIftar(
                              icon: Icons.wb_twilight_rounded,
                              label: l.iftar,
                              time: context.clock(list[4].time),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.lg),
                for (final pr in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.sm),
                    child: AnimatedContainer(
                      duration: Motion.medium,
                      decoration: BoxDecoration(
                        color: pr.key == next.key && pr.time == next.time ? p.primary : p.surface,
                        borderRadius: Radii.cardBorder,
                        boxShadow: softShadow(p.isDark),
                        border: p.isDark ? Border.all(color: p.border) : null,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
                      child: Builder(
                        builder: (context) {
                          final isNext = pr.key == next.key && pr.time == next.time;
                          final passed = pr.time.isBefore(now);
                          final fg = isNext ? Colors.white : (passed ? p.muted : p.text);
                          return Row(
                            children: [
                              Icon(icons[pr.key], color: isNext ? Colors.white : p.primary),
                              const SizedBox(width: Gap.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(prayerName(l, pr.key), style: context.text.titleMedium?.copyWith(color: fg)),
                                    if (isNext) Pill(l.nextPrayer, color: Colors.white, dense: true),
                                  ],
                                ),
                              ),
                              if (passed && !isNext) Icon(Icons.check_rounded, size: 18, color: p.success),
                              const SizedBox(width: Gap.sm),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    context.clock(pr.time),
                                    style: context.text.titleMedium?.copyWith(color: fg),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: Gap.sm),
                Text(l.prayerSource, style: context.text.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SehriIftar extends StatelessWidget {
  const _SehriIftar({required this.icon, required this.label, required this.time});
  final IconData icon;
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: Radii.buttonBorder),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: Gap.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.text.labelSmall?.copyWith(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(time, style: context.text.titleSmall?.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;
    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}
