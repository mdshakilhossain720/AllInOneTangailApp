import 'package:material_ui/material_ui.dart';

enum ScreenSize { compact, phone, largePhone, tablet }

/// Width breakpoints:
/// compact < 360, phone 360–599, large phone / foldable 600–839, tablet ≥ 840.
abstract final class AppBreakpoints {
  static const double phone = 360;
  static const double largePhone = 600;
  static const double tablet = 840;

  /// Max width for reading-style content on very wide screens.
  static const double maxContent = 1200;

  static ScreenSize of(double width) {
    if (width >= tablet) return ScreenSize.tablet;
    if (width >= largePhone) return ScreenSize.largePhone;
    if (width >= phone) return ScreenSize.phone;
    return ScreenSize.compact;
  }

  /// Picks a value for the given size; larger sizes fall back to smaller ones.
  static T value<T>(double width, {required T compact, T? phone, T? largePhone, T? tablet}) {
    final p = phone ?? compact;
    final lp = largePhone ?? p;
    final t = tablet ?? lp;
    return switch (of(width)) {
      ScreenSize.compact => compact,
      ScreenSize.phone => p,
      ScreenSize.largePhone => lp,
      ScreenSize.tablet => t,
    };
  }

  /// Category grid columns: 4 → 5 → 6 → 8.
  /// Narrow phones (< 400) keep 4 so Bangla labels have room.
  static int categoryColumns(double width) {
    if (width >= tablet) return 8;
    if (width >= largePhone) return 6;
    if (width >= 400) return 5;
    return 4;
  }

  /// Product grid columns: 2 → 3 → 4.
  static int productColumns(double width) => value(width, compact: 2, phone: 2, largePhone: 3, tablet: 4);
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  ScreenSize get screenSize => AppBreakpoints.of(screenWidth);
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isCompact => screenSize == ScreenSize.compact;

  /// Horizontal page padding that grows on large screens.
  double get pagePadding =>
      AppBreakpoints.value(screenWidth, compact: 12.0, phone: 16.0, largePhone: 24.0, tablet: 24.0);

  /// Multiplier for the current system text scale, used to size horizontal
  /// lists so content never overflows at large font sizes.
  double get textScale => MediaQuery.textScalerOf(this).scale(14) / 14;

  /// Scales a base extent by the text scale (capped) — for horizontal list
  /// heights that must contain text.
  double scaled(double base) => base * textScale.clamp(1.0, 1.6);
}

/// Builds a different layout per breakpoint, based on the *available* width
/// (so it also works inside split panes).
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.compact, this.phone, this.largePhone, this.tablet});

  final WidgetBuilder compact;
  final WidgetBuilder? phone;
  final WidgetBuilder? largePhone;
  final WidgetBuilder? tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final builder = AppBreakpoints.value<WidgetBuilder>(
          constraints.maxWidth,
          compact: compact,
          phone: phone,
          largePhone: largePhone,
          tablet: tablet,
        );
        return builder(context);
      },
    );
  }
}

/// Centers content and caps its width on large screens.
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child, this.maxWidth = AppBreakpoints.maxContent});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
