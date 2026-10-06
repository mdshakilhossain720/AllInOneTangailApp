import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/shop_data.dart';
import '../../widgets/widgets.dart';

final _vacationProvider = settable<bool>(false);
final _autoReplyProvider = settable<bool>(true);

/// Store settings and payouts (UI only).
class StoreSettingsScreen extends ConsumerWidget {
  const StoreSettingsScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final store = storeById('s1');
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab.clamp(0, 1),
      child: AppScaffold(
        title: l.storeSettings,
        bottom: TabBar(
          tabAlignment: TabAlignment.fill,
          tabs: [
            Tab(text: l.storeSettings),
            Tab(text: l.payouts),
          ],
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: EdgeInsets.all(context.pagePadding),
              children: [
                AspectRatio(
                  aspectRatio: 2.6,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(store.cover, radius: Radii.card),
                      Positioned(
                        right: Gap.sm,
                        bottom: Gap.sm,
                        child: FilledButton.tonalIcon(
                          onPressed: () => context.toast(l.comingSoonDemo),
                          icon: const Icon(Icons.photo_camera_outlined, size: 18),
                          label: Text(l.edit),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.lg),
                AppTextField(label: l.storeName, initialValue: store.name, prefixIcon: Icons.store_outlined),
                AppTextField(label: l.storeDescription, initialValue: store.about, maxLines: 3),
                AppTextField(
                  label: l.phone,
                  initialValue: store.phone,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.beach_access_outlined),
                        title: Text(l.vacationMode),
                        subtitle: Text(context.isBn ? 'অর্ডার সাময়িক বন্ধ রাখুন' : 'Pause new orders temporarily'),
                        value: ref.watch(_vacationProvider),
                        onChanged: (v) => ref.read(_vacationProvider.notifier).set(v),
                      ),
                      Divider(color: p.border),
                      SwitchListTile(
                        secondary: const Icon(Icons.quickreply_outlined),
                        title: Text(l.autoReply),
                        value: ref.watch(_autoReplyProvider),
                        onChanged: (v) => ref.read(_autoReplyProvider.notifier).set(v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.xl),
                PrimaryButton(label: l.save, onPressed: () => context.toast(l.settingsSaved)),
              ],
            ),
            ListView(
              padding: EdgeInsets.all(context.pagePadding),
              children: [
                Container(
                  padding: const EdgeInsets.all(Gap.xl),
                  decoration: BoxDecoration(gradient: p.headerGradient, borderRadius: Radii.cardBorder),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.availableBalance, style: context.text.bodyMedium?.copyWith(color: Colors.white70)),
                      const SizedBox(height: Gap.xs),
                      FittedBox(
                        child: Text(
                          context.taka(18450),
                          style: context.text.displaySmall?.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: Gap.xs),
                      Text('bKash ••• 4521', style: context.text.bodySmall?.copyWith(color: Colors.white70)),
                      const SizedBox(height: Gap.lg),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: p.isDark ? AppColors.primaryDark : AppColors.primary,
                        ),
                        onPressed: () => _withdraw(context),
                        icon: const Icon(Icons.arrow_downward_rounded),
                        label: Text(l.withdraw),
                      ),
                    ],
                  ),
                ),
                SectionHeader(
                  l.payoutHistory,
                  padding: const EdgeInsets.only(top: Gap.xl, bottom: Gap.sm),
                ),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final (i, (date, amount, method)) in payoutHistory.indexed) ...[
                        if (i > 0) Divider(height: 1, color: p.border),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: p.primarySoft,
                            child: Icon(Icons.call_made_rounded, color: p.primary, size: 18),
                          ),
                          title: Text(context.taka(amount)),
                          subtitle: Text('${context.digits(date)} · $method'),
                          trailing: StatusChip(l.completed, tone: StatusTone.success),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _withdraw(BuildContext context) async {
    final l = context.l10n;
    final ok = await showAppSheet<bool>(
      context,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetTitle(l.withdraw, subtitle: '${l.availableBalance}: ${ctx.taka(18450)}'),
          AppTextField(
            label: '${l.amount} (৳)',
            initialValue: '18450',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.payments_outlined,
          ),
          PrimaryButton(label: l.confirm, onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (ok == true && context.mounted) context.toast(l.withdrawRequested);
  }
}
