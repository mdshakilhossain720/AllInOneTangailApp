import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/shop_data.dart';
import '../../data/models.dart';
import '../../widgets/widgets.dart';

/// Vouchers & coins wallet (demo points).
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final coins = ref.watch(coinsProvider);
    final checkedIn = ref.watch(checkedInTodayProvider);
    final collected = ref.watch(collectedVouchersProvider);

    return AppScaffold(
      title: l.vouchersWallet,
      body: ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          Container(
            padding: const EdgeInsets.all(Gap.xl),
            decoration: BoxDecoration(
              borderRadius: Radii.cardBorder,
              gradient: const LinearGradient(
                colors: [Color(0xFFF4A261), Color(0xFFE76F51)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Colors.white),
                    const SizedBox(width: Gap.sm),
                    Flexible(
                      child: Text(l.coinsBalance, style: context.text.titleSmall?.copyWith(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.sm),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: coins - (checkedIn ? 10 : 0), end: coins),
                  duration: Motion.slow,
                  builder: (_, v, _) =>
                      Text(context.digits(v), style: context.text.displaySmall?.copyWith(color: Colors.white)),
                ),
                Text(
                  context.isBn
                      ? '= ${context.taka(coins ~/ 10)} ছাড়'
                      : '= ${context.taka(coins ~/ 10)} off at checkout',
                  style: context.text.bodySmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: Gap.lg),
                // 7-day check-in streak.
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: i < 3 || (i == 3 && checkedIn)
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              child: Text(
                                context.digits('+${i == 6 ? 50 : 10}'),
                                style: context.text.labelSmall?.copyWith(color: const Color(0xFFE76F51), fontSize: 9),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.digits('D${i + 1}'),
                              style: context.text.labelSmall?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Gap.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFC2611A),
                    ),
                    onPressed: checkedIn
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            ref.read(checkedInTodayProvider.notifier).set(true);
                            ref.read(coinsProvider.notifier).set(coins + 10);
                            context.toast(l.checkedIn);
                          },
                    child: Text(checkedIn ? '✓ ${l.dailyCheckIn}' : l.dailyCheckIn),
                  ),
                ),
              ],
            ),
          ),
          SectionHeader(
            l.myVouchers,
            padding: const EdgeInsets.only(top: Gap.xl, bottom: Gap.sm),
          ),
          for (final v in vouchers) ...[
            _VoucherTicket(
              voucher: v,
              collected: collected.contains(v.id),
              onCollect: () {
                ref.read(collectedVouchersProvider.notifier).toggle(v.id);
                context.toast('${l.collected}: ${v.title}');
              },
              onUse: () => context.go('/shop'),
            ),
            const SizedBox(height: Gap.md),
          ],
        ],
      ),
    );
  }
}

class _VoucherTicket extends StatelessWidget {
  const _VoucherTicket({required this.voucher, required this.collected, required this.onCollect, required this.onUse});
  final Voucher voucher;
  final bool collected;
  final VoidCallback onCollect;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return ClipPath(
      clipper: _TicketClipper(),
      child: Container(
        color: p.surface,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 96,
                color: voucher.storeName == null ? p.primary : AppColors.secondary,
                padding: const EdgeInsets.all(Gap.sm),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: Text(
                        context.taka(voucher.amount),
                        style: context.text.headlineSmall?.copyWith(color: Colors.white),
                      ),
                    ),
                    Text('OFF', style: context.text.labelSmall?.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Gap.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(voucher.title, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (voucher.storeName != null)
                        Text(
                          voucher.storeName!,
                          style: context.text.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(l.minSpend(context.digits(voucher.minSpend)), style: context.text.bodySmall),
                      Text(
                        l.validTill(context.shortDate(voucher.validTill)),
                        style: context.text.labelSmall?.copyWith(color: p.emergency),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: Gap.md),
                child: Center(
                  child: collected
                      ? OutlinedButton(onPressed: onUse, child: Text(l.useNow))
                      : FilledButton(onPressed: onCollect, child: Text(l.collect)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded rectangle with semicircle notches, like a paper ticket.
class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const r = 10.0;
    const notchX = 96.0;
    final rect = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(Radii.card)));
    final notches = Path()
      ..addOval(Rect.fromCircle(center: const Offset(notchX, 0), radius: r))
      ..addOval(Rect.fromCircle(center: Offset(notchX, size.height), radius: r));
    return Path.combine(PathOperation.difference, rect, notches);
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) => false;
}
