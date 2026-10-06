import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/demo/health_data.dart';
import '../../widgets/widgets.dart';

/// Red floating SOS button.
/// • Tap → emergency contacts sheet.
/// • Press and hold 2 s (progress ring fills) → "Calling 999" countdown dialog.
class SosButton extends StatefulWidget {
  const SosButton({super.key, this.mini = false});
  final bool mini;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  late final _hold = AnimationController(vsync: this, duration: const Duration(seconds: 2))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _triggered();
    });
  DateTime? _downAt;
  bool _fired = false;

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  void _down() {
    _fired = false;
    _downAt = DateTime.now();
    _hold.forward(from: 0);
    HapticFeedback.lightImpact();
  }

  void _up() {
    final quick = _downAt != null && DateTime.now().difference(_downAt!) < const Duration(milliseconds: 350);
    if (!_fired) {
      _hold.reverse();
      if (quick) showSosSheet(context);
    }
    _downAt = null;
  }

  void _triggered() {
    _fired = true;
    HapticFeedback.heavyImpact();
    _hold.value = 0;
    showDialog<void>(context: context, barrierDismissible: false, builder: (_) => const _Calling999Dialog());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final size = widget.mini ? 52.0 : 62.0;
    return Semantics(
      button: true,
      label: '${context.l10n.sos}. ${context.l10n.sosSubtitle}',
      excludeSemantics: true,
      onTap: () => showSosSheet(context),
      onLongPress: _triggered,
      child: Listener(
        onPointerDown: (_) => _down(),
        onPointerUp: (_) => _up(),
        onPointerCancel: (_) => _hold.reverse(),
        child: AnimatedBuilder(
          animation: _hold,
          builder: (context, _) {
            return SizedBox.square(
              dimension: size + 10,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.square(
                    dimension: size + 8,
                    child: CircularProgressIndicator(
                      value: _hold.value,
                      strokeWidth: 4,
                      color: p.emergency,
                      backgroundColor: _hold.value > 0 ? p.emergency.withValues(alpha: 0.15) : Colors.transparent,
                    ),
                  ),
                  Transform.scale(
                    scale: 1 - 0.06 * _hold.value,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: p.emergency,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: p.emergency.withValues(alpha: 0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.sos_rounded, color: Colors.white, size: 26),
                          if (_hold.value > 0.05 && !widget.mini)
                            Text(
                              context.l10n.holdForSos,
                              style: context.text.labelSmall?.copyWith(color: Colors.white, fontSize: 8),
                              maxLines: 1,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> showSosSheet(BuildContext context) {
  final l = context.l10n;
  final p = context.palette;
  final rows = <(IconData, String, String, String?)>[
    (Icons.local_phone_rounded, l.nationalEmergency, '999', null),
    (Icons.emergency_rounded, l.ambulance, ambulances.first.phone, ambulances.first.provider),
    (
      Icons.local_fire_department_rounded,
      l.fireService,
      emergencyServices.firstWhere((e) => e.id == 'f1').phone,
      'Tangail Fire Station',
    ),
    (Icons.local_police_rounded, l.police, emergencyServices.first.phone, emergencyServices.first.name),
    (
      Icons.local_hospital_rounded,
      l.nearestHospital,
      hospitals.first.phone,
      '${hospitals.first.name} · ${context.l10n.km(context.digits('1.2'))}',
    ),
  ];
  return showAppSheet<void>(
    context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: p.emergencySoft, shape: BoxShape.circle),
              child: Icon(Icons.sos_rounded, color: p.emergency),
            ),
            const SizedBox(width: Gap.md),
            Expanded(child: Text(l.sosTitle, style: ctx.text.headlineSmall)),
          ],
        ),
        const SizedBox(height: Gap.sm),
        Text(l.sosSubtitle, style: ctx.text.bodySmall),
        const SizedBox(height: Gap.lg),
        for (final (icon, title, number, sub) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.sm),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
              border: Border.all(color: p.emergency.withValues(alpha: 0.35)),
              onTap: () => confirmCall(ctx, name: title, number: number),
              child: Row(
                children: [
                  Icon(icon, color: p.emergency),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: ctx.text.titleSmall),
                        Text(
                          sub ?? ctx.digits(number),
                          style: ctx.text.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (number == '999')
                    Text(
                      ctx.digits('999'),
                      style: ctx.text.headlineSmall?.copyWith(color: p.emergency, fontWeight: FontWeight.w800),
                    ),
                  const SizedBox(width: Gap.sm),
                  CallButton(name: title, number: number, color: p.emergency),
                ],
              ),
            ),
          ),
        const SizedBox(height: Gap.sm),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            context.push('/explore/blood');
          },
          icon: Icon(Icons.bloodtype_rounded, color: p.emergency),
          label: Text(l.bloodDonors),
        ),
      ],
    ),
  );
}

class _Calling999Dialog extends StatefulWidget {
  const _Calling999Dialog();

  @override
  State<_Calling999Dialog> createState() => _Calling999DialogState();
}

class _Calling999DialogState extends State<_Calling999Dialog> {
  static const _total = 5;
  int _left = _total;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 1) {
        t.cancel();
        Navigator.of(context).pop();
        context.toast(context.l10n.callingDemo('999'));
        return;
      }
      setState(() => _left--);
      HapticFeedback.selectionClick();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AlertDialog(
      icon: Icon(Icons.call_rounded, color: p.emergency, size: 36),
      title: Text(context.l10n.calling999, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: (_left) / _total, end: (_left - 1) / _total),
                    duration: const Duration(seconds: 1),
                    builder: (_, v, _) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 8,
                      color: p.emergency,
                      backgroundColor: p.emergencySoft,
                    ),
                  ),
                ),
                Text(context.digits(_left), style: context.text.displaySmall?.copyWith(color: p.emergency)),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),
          Text(context.l10n.callingIn(context.digits(_left)), textAlign: TextAlign.center),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.text, foregroundColor: p.surface),
            onPressed: () {
              Navigator.pop(context);
              context.toast(context.l10n.callCancelled);
            },
            child: Text(context.l10n.cancel),
          ),
        ),
      ],
    );
  }
}
