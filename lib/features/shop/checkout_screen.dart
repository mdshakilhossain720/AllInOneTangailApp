import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/common_data.dart';
import '../../data/demo/shop_data.dart';
import '../../data/models.dart';
import '../../widgets/widgets.dart';
import '../profile/address_form.dart';

enum PayMethod { cod, bkash, nagad, rocket, card }

/// Checkout stepper: Address → Delivery → Payment → Review.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0;
  late String _addressId = ref.read(defaultAddressProvider);
  bool _pickup = false;
  PayMethod _pay = PayMethod.cod;
  bool _placing = false;

  Address get _address => ref
      .read(addressesProvider)
      .firstWhere((a) => a.id == _addressId, orElse: () => ref.read(addressesProvider).first);

  int get _deliveryFee => _pickup ? 0 : deliveryFor(_address.upazila).$1;

  String _payLabel(PayMethod m) => switch (m) {
    PayMethod.cod => context.l10n.cod,
    PayMethod.bkash => 'bKash',
    PayMethod.nagad => 'Nagad',
    PayMethod.rocket => 'Rocket',
    PayMethod.card => context.l10n.card,
  };

  Future<void> _placeOrder() async {
    setState(() => _placing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final selected = ref.read(cartProvider).where((e) => e.selected).toList();
    final id = 'TAO-${250000 + Random().nextInt(9999)}';
    ref
        .read(ordersProvider.notifier)
        .add(
          Order(
            id: id,
            lines: [for (final e in selected) OrderLine(e.productId, e.qty, productById(e.productId).price)],
            status: _pay == PayMethod.cod ? OrderStatus.toShip : OrderStatus.toPay,
            placedAt: DateTime.now(),
            payment: _payLabel(_pay),
            deliveryFee: _deliveryFee,
            address: _pickup ? context.l10n.localPickup : '${_address.line}, ${_address.upazila}',
          ),
        );
    ref.read(cartProvider.notifier).removeSelected();
    ref.read(appliedVoucherProvider.notifier).set(0);
    context.go('/order-success?id=$id');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final totals = ref.watch(cartTotalsProvider);
    final voucher = ref.watch(appliedVoucherProvider);
    final total = totals.subtotal + _deliveryFee - voucher;
    final steps = [l.stepAddress, l.stepDelivery, l.stepPayment, l.stepReview];

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: AppScaffold(
        title: l.checkout,
        bottomBar: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.total, style: context.text.bodySmall),
                  PriceText(total),
                ],
              ),
            ),
            if (_step > 0) ...[
              OutlinedButton(onPressed: () => setState(() => _step--), child: Text(l.back)),
              const SizedBox(width: Gap.sm),
            ],
            FilledButton(
              onPressed: _placing ? null : () => _step < 3 ? setState(() => _step++) : _placeOrder(),
              child: _placing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : Text(_step < 3 ? l.next : l.placeOrder),
            ),
          ],
        ),
        body: Column(
          children: [
            _StepHeader(steps: steps, current: _step, onTap: (i) => i < _step ? setState(() => _step = i) : null),
            Expanded(
              child: AnimatedSwitcher(
                duration: Motion.medium,
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0.05, 0), end: Offset.zero).animate(a),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: ListView(
                    padding: EdgeInsets.all(context.pagePadding),
                    children: switch (_step) {
                      0 => _addressStep(),
                      1 => _deliveryStep(),
                      2 => _paymentStep(),
                      _ => _reviewStep(totals, voucher, total),
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _addressStep() {
    final l = context.l10n;
    final p = context.palette;
    final addresses = ref.watch(addressesProvider);
    return [
      for (final a in addresses)
        Padding(
          padding: const EdgeInsets.only(bottom: Gap.md),
          child: _SelectableCard(
            selected: _addressId == a.id,
            onTap: () => setState(() => _addressId = a.id),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  a.label == 'Home'
                      ? Icons.home_rounded
                      : (a.label == 'Office' ? Icons.work_rounded : Icons.family_restroom_rounded),
                  color: p.primary,
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: Gap.sm,
                        children: [
                          Text(a.label, style: context.text.titleSmall),
                          if (a.id == ref.watch(defaultAddressProvider))
                            Pill(l.defaultAddress, color: p.primary, dense: true),
                        ],
                      ),
                      Text('${a.name} · ${context.digits(a.phone)}', style: context.text.bodySmall),
                      Text('${a.line}, ${upazilaName(a.upazila).of(context)}', style: context.text.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      OutlinedButton.icon(
        onPressed: () async {
          final added = await showAddressForm(context, ref);
          if (added != null) setState(() => _addressId = added.id);
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: Text(l.addNewAddress),
      ),
    ];
  }

  List<Widget> _deliveryStep() {
    final l = context.l10n;
    final p = context.palette;
    final (fee, days) = deliveryFor(_address.upazila);
    return [
      _SelectableCard(
        selected: !_pickup,
        onTap: () => setState(() => _pickup = false),
        child: Row(
          children: [
            PastelIcon(Icons.local_shipping_rounded, index: 0),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.homeDelivery, style: context.text.titleSmall),
                  Text(
                    '${upazilaName(_address.upazila).of(context)} · ${l.estDelivery(context.digits(days))}',
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            Text(context.taka(fee), style: context.text.titleSmall),
          ],
        ),
      ),
      const SizedBox(height: Gap.md),
      _SelectableCard(
        selected: _pickup,
        onTap: () => setState(() => _pickup = true),
        child: Row(
          children: [
            PastelIcon(Icons.storefront_rounded, index: 6),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.localPickup, style: context.text.titleSmall),
                  Text(l.pickupAvailable, style: context.text.bodySmall?.copyWith(color: p.success)),
                ],
              ),
            ),
            Text(context.taka(0), style: context.text.titleSmall?.copyWith(color: p.success)),
          ],
        ),
      ),
      if (_pickup) ...[
        const SizedBox(height: Gap.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final storeId in {
                for (final e in ref.watch(cartProvider).where((e) => e.selected)) productById(e.productId).storeId,
              })
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_rounded),
                  title: Text(storeById(storeId).name),
                  subtitle: Text(upazilaName(storeById(storeId).upazila).of(context)),
                ),
            ],
          ),
        ),
      ],
    ];
  }

  List<Widget> _paymentStep() {
    final p = context.palette;
    final methods = [
      (PayMethod.cod, Icons.payments_rounded, p.success),
      (PayMethod.bkash, Icons.account_balance_wallet_rounded, AppColors.bkash),
      (PayMethod.nagad, Icons.account_balance_wallet_rounded, AppColors.nagad),
      (PayMethod.rocket, Icons.rocket_launch_rounded, AppColors.rocket),
      (PayMethod.card, Icons.credit_card_rounded, p.info),
    ];
    return [
      LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth >= 520 ? 3 : 2;
          final w = (c.maxWidth - (cols - 1) * Gap.md) / cols;
          return Wrap(
            spacing: Gap.md,
            runSpacing: Gap.md,
            children: [
              for (final (m, icon, color) in methods)
                SizedBox(
                  width: m == PayMethod.cod && cols == 2 ? c.maxWidth : w,
                  child: Semantics(
                    selected: _pay == m,
                    button: true,
                    child: PressableScale(
                      onTap: () => setState(() => _pay = m),
                      child: AnimatedContainer(
                        duration: Motion.fast,
                        constraints: const BoxConstraints(minHeight: 72),
                        padding: const EdgeInsets.all(Gap.md),
                        decoration: BoxDecoration(
                          color: _pay == m ? color.withValues(alpha: p.isDark ? 0.25 : 0.1) : p.surface,
                          borderRadius: Radii.cardBorder,
                          border: Border.all(color: _pay == m ? color : p.border, width: _pay == m ? 2 : 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(Gap.sm),
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                              child: Icon(icon, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: Gap.sm),
                            Expanded(
                              child: Text(
                                _payLabel(m),
                                style: context.text.titleSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_pay == m) Icon(Icons.check_circle_rounded, color: color),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: Gap.lg),
      if (_pay != PayMethod.cod)
        AppCard(
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: p.info),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Text(
                  context.isBn
                      ? '${_payLabel(_pay)} পেমেন্ট পেজে নিয়ে যাওয়া হবে (ডেমো — কোনো টাকা কাটা হবে না)।'
                      : 'You\'ll be redirected to ${_payLabel(_pay)} to pay (demo — no money is charged).',
                  style: context.text.bodySmall,
                ),
              ),
            ],
          ),
        ),
    ];
  }

  List<Widget> _reviewStep(({int subtotal, int savings, int count}) totals, int voucher, int total) {
    final l = context.l10n;
    final p = context.palette;
    final items = ref.watch(cartProvider).where((e) => e.selected).toList();
    return [
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.orderSummary, style: context.text.titleMedium),
            const SizedBox(height: Gap.sm),
            for (final e in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Gap.xs),
                child: Row(
                  children: [
                    SizedBox.square(dimension: 48, child: AppImage(productById(e.productId).images.first, radius: 8)),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Text(
                        productById(e.productId).name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium,
                      ),
                    ),
                    Text(context.digits('×${e.qty}'), style: context.text.bodySmall),
                    const SizedBox(width: Gap.sm),
                    Text(context.taka(productById(e.productId).price * e.qty), style: context.text.titleSmall),
                  ],
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: Gap.md),
      AppCard(
        child: Column(
          children: [
            _ReviewRow(
              Icons.location_on_outlined,
              l.stepAddress,
              _pickup ? l.localPickup : '${_address.line}, ${upazilaName(_address.upazila).of(context)}',
              () => setState(() => _step = 0),
            ),
            _ReviewRow(
              Icons.local_shipping_outlined,
              l.stepDelivery,
              _pickup ? l.localPickup : l.homeDelivery,
              () => setState(() => _step = 1),
            ),
            _ReviewRow(Icons.payments_outlined, l.stepPayment, _payLabel(_pay), () => setState(() => _step = 2)),
          ],
        ),
      ),
      const SizedBox(height: Gap.md),
      AppCard(
        child: Column(
          children: [
            KeyValueRow(l.subtotal, context.taka(totals.subtotal)),
            KeyValueRow(l.deliveryFee, context.taka(_deliveryFee)),
            if (voucher > 0) KeyValueRow(l.voucher, '- ${context.taka(voucher)}', valueColor: p.success),
            const Divider(height: Gap.xl),
            KeyValueRow(l.total, context.taka(total), bold: true),
          ],
        ),
      ),
    ];
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.icon, this.label, this.value, this.onEdit);
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label, style: context.text.bodySmall),
      subtitle: Text(value, style: context.text.bodyMedium),
      trailing: TextButton(onPressed: onEdit, child: Text(context.l10n.change)),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({required this.selected, required this.onTap, required this.child});
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      selected: selected,
      button: true,
      child: AppCard(
        onTap: onTap,
        border: Border.all(color: selected ? p.primary : p.border, width: selected ? 2 : 1),
        color: selected ? (p.isDark ? p.surfaceAlt : p.primarySoft.withValues(alpha: 0.4)) : null,
        child: Row(
          children: [
            Expanded(child: child),
            const SizedBox(width: Gap.sm),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? p.primary : p.muted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal step indicator with connecting lines.
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.steps, required this.current, required this.onTap});
  final List<String> steps;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      color: p.surface,
      padding: const EdgeInsets.symmetric(vertical: Gap.md, horizontal: Gap.sm),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                borderRadius: Radii.buttonBorder,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: Motion.medium,
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: i <= current ? p.primary : p.surfaceAlt,
                        shape: BoxShape.circle,
                        border: Border.all(color: i <= current ? p.primary : p.border),
                      ),
                      alignment: Alignment.center,
                      child: i < current
                          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                          : Text(
                              context.digits(i + 1),
                              style: context.text.labelMedium?.copyWith(color: i == current ? Colors.white : p.muted),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        color: i <= current ? p.primary : p.muted,
                        fontWeight: i == current ? FontWeight.w700 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
