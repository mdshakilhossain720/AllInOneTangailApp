import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/state/providers.dart';
import '../../../data/models.dart';
import '../../../widgets/widgets.dart';

/// Event detail bottom sheet with an "Interested" toggle.
Future<void> showEventSheet(BuildContext context, LocalEvent e) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => Consumer(
      builder: (ctx, ref, _) {
        final interested = ref.watch(interestedEventsProvider).contains(e.id);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: AppImage(e.image, radius: Radii.card),
            ),
            const SizedBox(height: Gap.lg),
            Pill(e.category, color: ctx.palette.info),
            const SizedBox(height: Gap.sm),
            Text(e.title, style: ctx.text.headlineSmall),
            const SizedBox(height: Gap.sm),
            _row(
              ctx,
              Icons.event_rounded,
              ctx.digits(DateFormat('EEEE, d MMMM', ctx.isBn ? 'bn' : 'en').format(e.date)),
            ),
            _row(ctx, Icons.place_outlined, e.place),
            const SizedBox(height: Gap.md),
            Text(e.description, style: ctx.text.bodyMedium),
            const SizedBox(height: Gap.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ctx.toast(ctx.l10n.sharedDemo),
                    icon: const Icon(Icons.share_rounded),
                    label: Text(ctx.l10n.share),
                  ),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: FilledButton.icon(
                    style: interested ? FilledButton.styleFrom(backgroundColor: ctx.palette.success) : null,
                    onPressed: () {
                      final added = ref.read(interestedEventsProvider.notifier).toggle(e.id);
                      if (added) ctx.toast(ctx.l10n.markedInterested);
                    },
                    icon: Icon(interested ? Icons.check_circle_rounded : Icons.star_border_rounded),
                    label: Text(ctx.l10n.interested),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

Widget _row(BuildContext context, IconData icon, String text) => Padding(
  padding: const EdgeInsets.only(bottom: Gap.xs),
  child: Row(
    children: [
      Icon(icon, size: 16, color: context.palette.muted),
      const SizedBox(width: Gap.sm),
      Expanded(child: Text(text, style: context.text.bodyMedium)),
    ],
  ),
);

/// Compact event card used in horizontal lists.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.width = 240});
  final LocalEvent event;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: width,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => showEventSheet(context, event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.card)),
                    child: AppImage(event.image),
                  ),
                  Positioned(
                    left: Gap.sm,
                    top: Gap.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Text(
                            context.digits(event.date.day),
                            style: context.text.titleMedium?.copyWith(color: p.primary, height: 1.1),
                          ),
                          Text(
                            DateFormat('MMM', context.isBn ? 'bn' : 'en').format(event.date),
                            style: context.text.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Gap.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 13, color: p.muted),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          event.place,
                          style: context.text.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
