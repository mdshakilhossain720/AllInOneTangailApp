import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../core/utils/context_ext.dart';

/// Smooth line chart with a soft gradient fill, for short series
/// (7-day prices, weekly sales).
class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.values,
    required this.labels,
    this.color,
    this.valueFormatter,
    this.height = 180,
    this.semanticLabel,
  });

  final List<double> values;
  final List<String> labels;
  final Color? color;
  final String Function(double)? valueFormatter;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = color ?? p.primary;
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final pad = (maxV - minV).abs() < 1 ? maxV * 0.1 + 1 : (maxV - minV) * 0.25;
    final fmt = valueFormatter ?? (v) => context.digits(v.round());
    final labelStyle = context.text.labelSmall?.copyWith(color: p.muted);

    return Semantics(
      label: semanticLabel ?? labels.indexed.map((e) => '${e.$2}: ${fmt(values[e.$1])}').join(', '),
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: LineChart(
          LineChartData(
            minY: minV - pad,
            maxY: maxV + pad,
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: ((maxV + pad) - (minV - pad)) / 3,
              getDrawingHorizontalLine: (_) => FlLine(color: p.border, strokeWidth: 1, dashArray: [4, 4]),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  interval: ((maxV + pad) - (minV - pad)) / 3,
                  getTitlesWidget: (v, meta) => v == meta.max || v == meta.min
                      ? const SizedBox.shrink()
                      : SideTitleWidget(
                          meta: meta,
                          child: Text(fmt(v), style: labelStyle),
                        ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 26,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= labels.length || v != i) return const SizedBox.shrink();
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(labels[i], style: labelStyle),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => p.text,
                getTooltipItems: (spots) => [
                  for (final s in spots)
                    LineTooltipItem(fmt(s.y), TextStyle(color: p.surface, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
                isCurved: true,
                curveSmoothness: 0.3,
                preventCurveOverShooting: true,
                color: c,
                barWidth: 3,
                dotData: FlDotData(
                  getDotPainter: (_, _, _, i) => FlDotCirclePainter(
                    radius: i == values.length - 1 ? 5 : 3,
                    color: p.surface,
                    strokeWidth: 2.5,
                    strokeColor: c,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [c.withValues(alpha: 0.28), c.withValues(alpha: 0)],
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 400),
        ),
      ),
    );
  }
}

/// Simple rounded bar chart with the highest bar highlighted.
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.color,
    this.height = 200,
    this.valueFormatter,
  });

  final List<double> values;
  final List<String> labels;
  final Color? color;
  final double height;
  final String Function(double)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = color ?? p.primary;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final maxIndex = values.indexOf(maxV);
    final fmt = valueFormatter ?? (v) => context.compact(v.round());
    final labelStyle = context.text.labelSmall?.copyWith(color: p.muted);
    return Semantics(
      label: labels.indexed.map((e) => '${e.$2}: ${fmt(values[e.$1])}').join(', '),
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: BarChart(
          BarChartData(
            maxY: maxV * 1.2,
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: maxV * 1.2 / 4,
              getDrawingHorizontalLine: (_) => FlLine(color: p.border, strokeWidth: 1, dashArray: [4, 4]),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: maxV * 1.2 / 4,
                  getTitlesWidget: (v, meta) => v == meta.max
                      ? const SizedBox.shrink()
                      : SideTitleWidget(
                          meta: meta,
                          child: Text(fmt(v), style: labelStyle),
                        ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  getTitlesWidget: (v, meta) => SideTitleWidget(
                    meta: meta,
                    child: Text(labels[v.toInt()], style: labelStyle),
                  ),
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => p.text,
                getTooltipItem: (group, _, rod, _) =>
                    BarTooltipItem(context.taka(rod.toY), TextStyle(color: p.surface, fontWeight: FontWeight.w700)),
              ),
            ),
            barGroups: [
              for (var i = 0; i < values.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: values[i],
                      width: 18,
                      color: i == maxIndex ? c : c.withValues(alpha: 0.35),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                ),
            ],
          ),
          duration: const Duration(milliseconds: 400),
        ),
      ),
    );
  }
}
