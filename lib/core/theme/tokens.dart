import 'package:material_ui/material_ui.dart';

/// 8pt spacing grid.
abstract final class Gap {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class Radii {
  static const double card = 16;
  static const double button = 12;
  static const double chip = 20;
  static const double sheet = 24;

  static final cardBorder = BorderRadius.circular(card);
  static final buttonBorder = BorderRadius.circular(button);
  static final chipBorder = BorderRadius.circular(chip);
}

/// Type scale: display 28, h1 22, h2 18, title 16, body 14, caption 12.
abstract final class TypeScale {
  static const double display = 28;
  static const double h1 = 22;
  static const double h2 = 18;
  static const double title = 16;
  static const double body = 14;
  static const double caption = 12;
  static const double lineHeight = 1.4;
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 450);
}

/// Soft card shadow in light mode; dark mode uses borders instead (see
/// [AppDecorations.card]).
List<BoxShadow> softShadow(bool isDark) => isDark
    ? const []
    : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))];
