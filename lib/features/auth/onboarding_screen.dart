import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../widgets/widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final slides = [
      (
        l.onb1Title,
        l.onb1Body,
        Icons.location_city_rounded,
        [Icons.local_hospital_rounded, Icons.directions_bus_rounded, Icons.newspaper_rounded],
        p.primary,
      ),
      (
        l.onb2Title,
        l.onb2Body,
        Icons.storefront_rounded,
        [Icons.checkroom_rounded, Icons.cake_rounded, Icons.local_shipping_rounded],
        const Color(0xFFD9772B),
      ),
      (
        l.onb3Title,
        l.onb3Body,
        Icons.sos_rounded,
        [Icons.emergency_rounded, Icons.bloodtype_rounded, Icons.local_police_rounded],
        p.emergency,
      ),
    ];
    final last = _page == slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: MaxWidth(
          maxWidth: 640,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
                child: Row(
                  children: [
                    // Language quick switch.
                    IconButton(
                      tooltip: context.isBn ? 'English' : 'বাংলা',
                      onPressed: () {
                        final bn = ref.read(localeProvider).languageCode == 'bn';
                        ref.read(localeProvider.notifier).set(Locale(bn ? 'en' : 'bn'));
                      },
                      icon: const Icon(Icons.translate_rounded),
                    ),
                    const SizedBox(width: Gap.sm),
                    const DemoBadge(),
                    const Spacer(),
                    if (!last)
                      Flexible(
                        flex: 0,
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(l.skip, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) {
                    final (title, body, icon, orbit, color) = slides[i];
                    return LayoutBuilder(
                      builder: (context, c) => SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: c.maxHeight),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _Illustration(
                                icon: icon,
                                orbit: orbit,
                                color: color,
                                size: (c.maxHeight * 0.48).clamp(160.0, 300.0),
                              ),
                              const SizedBox(height: Gap.xxl),
                              Text(title, style: context.text.headlineMedium, textAlign: TextAlign.center),
                              const SizedBox(height: Gap.md),
                              Text(
                                body,
                                style: context.text.bodyLarge?.copyWith(color: p.muted),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              PageDots(count: slides.length, index: _page, activeColor: p.primary, inactiveColor: p.border),
              Padding(
                padding: const EdgeInsets.all(Gap.xl),
                child: PrimaryButton(
                  label: last ? l.getStarted : l.next,
                  icon: last ? Icons.arrow_forward_rounded : null,
                  onPressed: () =>
                      last ? context.go('/login') : _pc.nextPage(duration: Motion.slow, curve: Curves.easeOutCubic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Composed illustration: blob, main icon tile and orbiting mini icons.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.icon, required this.orbit, required this.color, required this.size});

  final IconData icon;
  final List<IconData> orbit;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.08), shape: BoxShape.circle),
          ),
          Container(
            width: size * 0.62,
            height: size * 0.62,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(size * 0.1),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: size * 0.2),
            ),
          ),
          for (var i = 0; i < orbit.length; i++)
            Align(
              alignment: [const Alignment(-0.85, -0.55), const Alignment(0.9, -0.2), const Alignment(-0.4, 0.9)][i],
              child: Container(
                padding: EdgeInsets.all(size * 0.04),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: softShadow(p.isDark),
                  border: p.isDark ? Border.all(color: p.border) : null,
                ),
                child: Icon(orbit[i], color: color, size: size * 0.1),
              ),
            ),
        ],
      ),
    );
  }
}
