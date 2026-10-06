import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/common_data.dart';
import '../../widgets/widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final prefs = ref.watch(notifPrefsProvider);
    void setPref(String k, bool v) => ref.read(notifPrefsProvider.notifier).set({...prefs, k: v});

    Widget group(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(top: Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: Gap.xs, bottom: Gap.sm),
            child: Text(title, style: context.text.labelLarge?.copyWith(color: p.muted)),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Gap.xs),
            child: Column(children: children),
          ),
        ],
      ),
    );

    return AppScaffold(
      title: l.settings,
      body: ListView(
        padding: EdgeInsets.fromLTRB(context.pagePadding, 0, context.pagePadding, Gap.xxl),
        children: [
          MaxWidth(
            maxWidth: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                group(l.language, [
                  Padding(
                    padding: const EdgeInsets.all(Gap.md),
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'bn', label: Text('বাংলা'), icon: Text('🇧🇩')),
                        ButtonSegment(value: 'en', label: Text('English'), icon: Icon(Icons.language_rounded)),
                      ],
                      selected: {ref.watch(localeProvider).languageCode},
                      onSelectionChanged: (s) => ref.read(localeProvider.notifier).set(Locale(s.first)),
                    ),
                  ),
                ]),
                group(l.theme, [
                  Padding(
                    padding: const EdgeInsets.all(Gap.md),
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(l.themeLight),
                          icon: const Icon(Icons.light_mode_rounded),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(l.themeDark),
                          icon: const Icon(Icons.dark_mode_rounded),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l.themeSystem),
                          icon: const Icon(Icons.brightness_auto_rounded),
                        ),
                      ],
                      selected: {ref.watch(themeModeProvider)},
                      onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
                    ),
                  ),
                ]),
                group(l.location, [
                  ListTile(
                    leading: Icon(Icons.location_on_outlined, color: p.primary),
                    title: Text(l.upazila),
                    subtitle: Text(upazilaById(ref.watch(upazilaProvider)).name.of(context)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/location?from=settings'),
                  ),
                ]),
                group(l.notifications, [
                  SwitchListTile(
                    secondary: Icon(Icons.notifications_active_outlined, color: p.primary),
                    title: Text(l.pushNotifications),
                    value: prefs['push']!,
                    onChanged: (v) => setPref('push', v),
                  ),
                  for (final (k, label, icon) in [
                    ('orders', l.orderUpdates, Icons.local_shipping_outlined),
                    ('offers', l.offersPromos, Icons.local_offer_outlined),
                    ('emergency', l.emergencyAlerts, Icons.warning_amber_rounded),
                    ('blood', l.bloodRequests, Icons.bloodtype_outlined),
                  ])
                    SwitchListTile(
                      secondary: Icon(icon, color: prefs['push']! ? p.muted : p.border),
                      title: Text(label),
                      value: prefs[k]! && prefs['push']!,
                      onChanged: prefs['push']! ? (v) => setPref(k, v) : null,
                    ),
                ]),
                group(l.demo, [
                  SwitchListTile(
                    secondary: Icon(Icons.cloud_off_rounded, color: p.muted),
                    title: Text(l.offlineDemo),
                    subtitle: Text(l.offlineDemoHint),
                    value: ref.watch(offlineProvider),
                    onChanged: (v) => ref.read(offlineProvider.notifier).set(v),
                  ),
                  ListTile(
                    leading: Icon(Icons.replay_rounded, color: p.muted),
                    title: Text(l.onb1Title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(l.replayOnboarding),
                    onTap: () => context.go('/onboarding'),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
