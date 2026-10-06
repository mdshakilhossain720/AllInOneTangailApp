import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../widgets/widgets.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  final _confetti = ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Gap.xl),
                child: MaxWidth(
                  maxWidth: 480,
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.elasticOut,
                        builder: (_, v, child) => Transform.scale(scale: v, child: child),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: p.success,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: p.success.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 4),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 72),
                        ),
                      ),
                      const SizedBox(height: Gap.xl),
                      Text(l.orderPlaced, style: context.text.headlineMedium, textAlign: TextAlign.center),
                      const SizedBox(height: Gap.sm),
                      Text(
                        l.orderPlacedBody,
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium?.copyWith(color: p.muted),
                      ),
                      const SizedBox(height: Gap.xl),
                      AppCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.orderId, style: context.text.bodySmall),
                                  Text(context.digits(widget.orderId), style: context.text.titleLarge),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Copy',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: widget.orderId));
                                context.toast('${widget.orderId} ✓');
                              },
                              icon: const Icon(Icons.copy_rounded),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Gap.xl),
                      PrimaryButton(
                        label: l.trackOrder,
                        icon: Icons.local_shipping_rounded,
                        onPressed: () {
                          context.go('/shop');
                          context.push('/orders/${widget.orderId}');
                        },
                      ),
                      const SizedBox(height: Gap.md),
                      PrimaryButton(label: l.continueShopping, outlined: true, onPressed: () => context.go('/shop')),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.06,
              numberOfParticles: 24,
              gravity: 0.25,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.emergency,
                AppColors.warning,
                AppColors.info,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
