import 'package:material_ui/material_ui.dart';

import '../core/theme/tokens.dart';
import '../core/utils/context_ext.dart';

enum TimelineState { done, current, upcoming }

/// One step in a vertical tracking timeline.
class TimelineTile extends StatelessWidget {
  const TimelineTile({
    super.key,
    required this.title,
    this.subtitle,
    this.time,
    this.state = TimelineState.done,
    this.isFirst = false,
    this.isLast = false,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final String? time;
  final TimelineState state;
  final bool isFirst;
  final bool isLast;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final active = state != TimelineState.upcoming;
    final color = active ? p.primary : p.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(width: 2, height: 6, color: isFirst ? Colors.transparent : color),
                Container(
                  width: state == TimelineState.current ? 24 : 18,
                  height: state == TimelineState.current ? 24 : 18,
                  decoration: BoxDecoration(
                    color: active ? p.primary : p.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                    boxShadow: state == TimelineState.current
                        ? [BoxShadow(color: p.primary.withValues(alpha: 0.35), blurRadius: 8, spreadRadius: 2)]
                        : null,
                  ),
                  child: active
                      ? Icon(
                          icon ?? Icons.check_rounded,
                          size: state == TimelineState.current ? 14 : 11,
                          color: Colors.white,
                        )
                      : null,
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : (state == TimelineState.done ? p.primary : p.border),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: Gap.xl, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleSmall?.copyWith(color: active ? p.text : p.muted)),
                  if (subtitle != null) Text(subtitle!, style: context.text.bodySmall),
                  if (time != null) Text(time!, style: context.text.labelSmall?.copyWith(color: p.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
