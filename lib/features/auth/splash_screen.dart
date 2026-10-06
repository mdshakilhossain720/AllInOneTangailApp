import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../widgets/widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = CurvedAnimation(
      parent: _c,
      curve: const Interval(0, 0.6, curve: Curves.elasticOut),
    );
    final text = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.4, 1, curve: Curves.easeOut),
    );
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.palette.headerGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles.
              Positioned(top: -60, right: -40, child: _circle(180, 0.08)),
              Positioned(bottom: 80, left: -50, child: _circle(140, 0.06)),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: logo,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.location_city_rounded, size: 52, color: context.palette.primary),
                            const Positioned(
                              right: 16,
                              top: 16,
                              child: Icon(Icons.favorite_rounded, size: 18, color: Color(0xFFE63946)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Gap.xl),
                    FadeTransition(
                      opacity: text,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(text),
                        child: Column(
                          children: [
                            Text(
                              context.l10n.appName,
                              textAlign: TextAlign.center,
                              style: context.text.displaySmall?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: Gap.sm),
                            Text(
                              'টাঙ্গাইল অল ইন ওয়ান',
                              style: context.text.titleMedium?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: Gap.xxl,
                child: FadeTransition(
                  opacity: text,
                  child: Column(
                    children: [
                      const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      ),
                      const SizedBox(height: Gap.md),
                      Text(context.l10n.appTagline, style: context.text.bodySmall?.copyWith(color: Colors.white70)),
                      const SizedBox(height: Gap.sm),
                      const DemoBadge(onDark: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: alpha),
      shape: BoxShape.circle,
    ),
  );
}
