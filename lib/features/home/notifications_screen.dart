import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/shop_data.dart';
import '../../data/models.dart';
import '../../widgets/widgets.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  (IconData, Color, String) _style(BuildContext context, NotifType t) {
    final p = context.palette;
    return switch (t) {
      NotifType.order => (Icons.local_shipping_rounded, p.primary, '/orders'),
      NotifType.offer => (Icons.local_offer_rounded, const Color(0xFFD9772B), '/wallet'),
      NotifType.emergency => (Icons.bloodtype_rounded, p.emergency, '/explore/blood'),
      NotifType.community => (Icons.campaign_rounded, p.info, '/explore/community'),
    };
  }

  String _ago(BuildContext context, int minutes) {
    if (minutes < 60) return context.l10n.minutesShort(context.digits(minutes));
    if (minutes < 1440) return context.digits('${minutes ~/ 60}h');
    return context.digits('${minutes ~/ 1440}d');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final read = ref.watch(readNotificationsProvider);
    final today = notificationsSeed.where((n) => n.minutesAgo < 1440).toList();
    final earlier = notificationsSeed.where((n) => n.minutesAgo >= 1440).toList();

    Widget tile(AppNotification n) {
      final (icon, color, route) = _style(context, n.type);
      final unread = !read.contains(n.id);
      return Padding(
        padding: const EdgeInsets.only(bottom: Gap.sm),
        child: AppCard(
          color: unread ? (p.isDark ? p.surfaceAlt : p.primarySoft.withValues(alpha: 0.45)) : null,
          padding: const EdgeInsets.all(Gap.md),
          onTap: () {
            if (unread) ref.read(readNotificationsProvider.notifier).toggle(n.id);
            context.push(route);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: context.text.titleSmall?.copyWith(fontWeight: unread ? FontWeight.w700 : FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(n.body, style: context.text.bodySmall),
                    const SizedBox(height: Gap.xs),
                    Text(_ago(context, n.minutesAgo), style: context.text.labelSmall?.copyWith(color: p.muted)),
                  ],
                ),
              ),
              if (unread)
                Container(
                  margin: const EdgeInsets.only(top: 6, left: Gap.sm),
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(color: p.emergency, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      title: l.notifications,
      maxWidth: true,
      actions: [
        IconButton(
          tooltip: l.markAllRead,
          icon: const Icon(Icons.done_all_rounded),
          onPressed: () {
            final n = ref.read(readNotificationsProvider.notifier);
            for (final x in notificationsSeed) {
              if (!ref.read(readNotificationsProvider).contains(x.id)) n.toggle(x.id);
            }
          },
        ),
      ],
      body: DemoLoader(
        builder: (_) => ListView(
          padding: const EdgeInsets.all(Gap.lg),
          children: [
            Text(l.today, style: context.text.titleMedium),
            const SizedBox(height: Gap.sm),
            ...today.map(tile),
            const SizedBox(height: Gap.md),
            Text(l.yesterday, style: context.text.titleMedium),
            const SizedBox(height: Gap.sm),
            ...earlier.map(tile),
          ],
        ),
      ),
    );
  }
}
