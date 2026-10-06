import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../core/utils/context_ext.dart';

/// Rebuilds every second with the remaining duration until [target].
class CountdownBuilder extends StatefulWidget {
  const CountdownBuilder({super.key, required this.target, required this.builder});

  final DateTime target;
  final Widget Function(BuildContext context, Duration remaining) builder;

  @override
  State<CountdownBuilder> createState() => _CountdownBuilderState();
}

class _CountdownBuilderState extends State<CountdownBuilder> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var left = widget.target.difference(DateTime.now());
    if (left.isNegative) left = Duration.zero;
    return widget.builder(context, left);
  }
}

/// HH : MM : SS boxes (used for flash sales).
class CountdownTimer extends StatelessWidget {
  const CountdownTimer({
    super.key,
    required this.target,
    this.color,
    this.textColor = Colors.white,
    this.compact = false,
  });

  final DateTime target;
  final Color? color;
  final Color textColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? context.palette.emergency;
    return CountdownBuilder(
      target: target,
      builder: (context, d) {
        String two(int n) => context.digits(n.toString().padLeft(2, '0'));
        final parts = [two(d.inHours), two(d.inMinutes % 60), two(d.inSeconds % 60)];
        Widget box(String s) => Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 6, vertical: 2),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
          child: Text(
            s,
            style: context.text.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );
        return Semantics(
          label: '${context.l10n.endsIn} ${d.inHours}h ${d.inMinutes % 60}m',
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              box(parts[0]),
              Text(
                ' : ',
                style: context.text.labelMedium?.copyWith(color: bg, fontWeight: FontWeight.w800),
              ),
              box(parts[1]),
              Text(
                ' : ',
                style: context.text.labelMedium?.copyWith(color: bg, fontWeight: FontWeight.w800),
              ),
              box(parts[2]),
            ],
          ),
        );
      },
    );
  }
}

/// "02h 14m 05s" text formatting.
String formatRemaining(BuildContext context, Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final s = d.inHours > 0
      ? '${two(d.inHours)}h ${two(d.inMinutes % 60)}m ${two(d.inSeconds % 60)}s'
      : '${two(d.inMinutes)}m ${two(d.inSeconds % 60)}s';
  return context.digits(s);
}
