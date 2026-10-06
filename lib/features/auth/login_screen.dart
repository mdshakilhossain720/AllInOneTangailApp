import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/common_data.dart';
import '../../widgets/widgets.dart';

/// Shared layout for the auth screens: gradient header + form card.
class _AuthLayout extends StatelessWidget {
  const _AuthLayout({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: p.headerGradient,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Gap.sm, Gap.sm, Gap.lg, Gap.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (showBack && context.canPop())
                            IconButton(
                              tooltip: context.l10n.back,
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                            )
                          else
                            const SizedBox(height: 48),
                          const Spacer(),
                          const DemoBadge(onDark: true),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: Gap.md, top: Gap.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(Gap.md),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(icon, color: Colors.white, size: 30),
                            ),
                            const SizedBox(height: Gap.lg),
                            Text(title, style: context.text.headlineMedium?.copyWith(color: Colors.white)),
                            const SizedBox(height: Gap.xs),
                            Text(
                              subtitle,
                              style: context.text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: MaxWidth(
                maxWidth: 520,
                child: Padding(padding: const EdgeInsets.all(Gap.xl), child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    context.push('/otp?phone=${Uri.encodeComponent(_phone.text)}');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _AuthLayout(
      icon: Icons.phone_iphone_rounded,
      title: l.loginTitle,
      subtitle: l.loginSubtitle,
      showBack: false,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              style: context.text.titleMedium?.copyWith(letterSpacing: 1.2),
              decoration: InputDecoration(
                labelText: l.mobileNumber,
                hintText: '01XXXXXXXXX',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: Gap.md, right: Gap.sm),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🇧🇩'),
                      const SizedBox(width: 6),
                      Text('+880', style: context.text.titleSmall),
                      const SizedBox(width: Gap.sm),
                      Container(width: 1, height: 22, color: context.palette.border),
                    ],
                  ),
                ),
              ),
              validator: (v) => (v == null || !RegExp(r'^01[3-9]\d{8}$').hasMatch(v)) ? l.invalidPhone : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: Gap.xl),
            PrimaryButton(label: l.sendOtp, loading: _loading, onPressed: _submit),
            const SizedBox(height: Gap.md),
            TextButton(onPressed: () => context.go('/location'), child: Text(l.continueAsGuest)),
            const SizedBox(height: Gap.lg),
            Text(l.termsNote, textAlign: TextAlign.center, style: context.text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  int _seconds = 30;
  Timer? _timer;
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _controller.addListener(() => setState(() => _error = false));
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) t.cancel();
      if (mounted) setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_controller.text.length < 6) {
      setState(() => _error = true);
      HapticFeedback.heavyImpact();
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) context.go('/location');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final code = _controller.text;
    return _AuthLayout(
      icon: Icons.sms_rounded,
      title: l.otpTitle,
      subtitle: l.otpSubtitle(context.digits(widget.phone.isEmpty ? '01700000001' : widget.phone)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hidden field drives the six visual boxes (supports paste & autofill).
          Stack(
            children: [
              Opacity(
                opacity: 0,
                child: SizedBox(
                  height: 56,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                    onChanged: (v) {
                      if (v.length == 6) _verify();
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _focus.requestFocus(),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final box = ((c.maxWidth - 5 * Gap.sm) / 6).clamp(36.0, 56.0);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 6; i++) ...[
                          if (i > 0) const SizedBox(width: Gap.sm),
                          AnimatedContainer(
                            duration: Motion.fast,
                            width: box,
                            height: box * 1.15,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: p.isDark ? p.surfaceAlt : p.surface,
                              borderRadius: Radii.buttonBorder,
                              border: Border.all(
                                width: i == code.length && _focus.hasFocus ? 2 : 1.2,
                                color: _error
                                    ? p.emergency
                                    : i < code.length
                                    ? p.primary
                                    : (i == code.length ? p.primary.withValues(alpha: 0.6) : p.border),
                              ),
                            ),
                            child: Text(
                              i < code.length ? context.digits(code[i]) : '',
                              style: context.text.headlineSmall,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(
            l.otpDemoHint,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(color: p.info),
          ),
          const SizedBox(height: Gap.xl),
          PrimaryButton(label: l.verify, loading: _loading, onPressed: _verify),
          const SizedBox(height: Gap.md),
          Center(
            child: _seconds > 0
                ? Text(l.resendIn(context.digits(_seconds)), style: context.text.bodyMedium?.copyWith(color: p.muted))
                : TextButton(
                    onPressed: () {
                      _startTimer();
                      context.toast(l.otpResent);
                    },
                    child: Text(l.resend),
                  ),
          ),
        ],
      ),
    );
  }
}

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key, this.fromSettings = false});
  final bool fromSettings;

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  late String _selected = ref.read(upazilaProvider);
  bool _detecting = false;

  Future<void> _detect() async {
    setState(() => _detecting = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _detecting = false;
      _selected = 'sadar';
    });
    context.toast(context.l10n.detectingLocation);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return _AuthLayout(
      icon: Icons.location_on_rounded,
      title: l.locationTitle,
      subtitle: l.locationSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: _detecting ? null : _detect,
            icon: _detecting
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location_rounded),
            label: Text(l.useCurrentLocation),
          ),
          const SizedBox(height: Gap.lg),
          Text(l.selectUpazila, style: context.text.titleMedium),
          const SizedBox(height: Gap.sm),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth < 340 ? 2 : 3;
              return Wrap(
                spacing: Gap.sm,
                runSpacing: Gap.sm,
                children: [
                  for (final u in upazilas)
                    SizedBox(
                      width: (c.maxWidth - (cols - 1) * Gap.sm) / cols,
                      child: PressableScale(
                        onTap: () => setState(() => _selected = u.id),
                        child: AnimatedContainer(
                          duration: Motion.fast,
                          constraints: const BoxConstraints(minHeight: 52),
                          padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: Gap.sm),
                          decoration: BoxDecoration(
                            color: _selected == u.id ? p.primarySoft : p.surface,
                            borderRadius: Radii.buttonBorder,
                            border: Border.all(
                              color: _selected == u.id ? p.primary : p.border,
                              width: _selected == u.id ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selected == u.id ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                size: 18,
                                color: _selected == u.id ? p.primary : p.muted,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  u.name.of(context),
                                  style: context.text.labelLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: Gap.xl),
          PrimaryButton(
            label: l.continueLabel,
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              ref.read(upazilaProvider.notifier).set(_selected);
              widget.fromSettings ? context.pop() : context.go('/home');
            },
          ),
        ],
      ),
    );
  }
}
