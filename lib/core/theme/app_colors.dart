import 'package:material_ui/material_ui.dart';

/// Raw brand colors. Prefer [AppPalette] (via `context.palette`) in widgets so
/// light/dark variants resolve automatically.
abstract final class AppColors {
  static const primary = Color(0xFF0B6E4F);
  static const primaryDark = Color(0xFF085A40);
  static const teal = Color(0xFF14A38B);
  static const secondary = Color(0xFFF4A261);
  static const emergency = Color(0xFFE63946);
  static const success = Color(0xFF2A9D8F);
  static const warning = Color(0xFFE9C46A);
  static const info = Color(0xFF457B9D);

  static const bgLight = Color(0xFFF7F8FA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textLight = Color(0xFF1D2433);
  static const mutedLight = Color(0xFF6B7280);
  static const borderLight = Color(0xFFE6E8EC);

  static const bgDark = Color(0xFF0F1417);
  static const surfaceDark = Color(0xFF182024);
  static const surfaceDark2 = Color(0xFF1F292E);
  static const textDark = Color(0xFFE8ECEF);
  static const mutedDark = Color(0xFF9AA4AE);
  static const borderDark = Color(0xFF2A363C);

  // Payment brand tiles (UI only).
  static const bkash = Color(0xFFE2136E);
  static const nagad = Color(0xFFF6921E);
  static const rocket = Color(0xFF8C3494);

  /// Pastel backgrounds used behind category icons, paired with a strong
  /// foreground of the same hue.
  static const pastels = <(Color, Color)>[
    (Color(0xFFE3F4EC), Color(0xFF0B6E4F)),
    (Color(0xFFFDEBDD), Color(0xFFD9772B)),
    (Color(0xFFFDE2E4), Color(0xFFD62839)),
    (Color(0xFFE2EEF6), Color(0xFF2F6690)),
    (Color(0xFFF1E8FB), Color(0xFF7B4FB8)),
    (Color(0xFFFCF4D9), Color(0xFFA77B06)),
    (Color(0xFFDDF3F1), Color(0xFF1E7F75)),
    (Color(0xFFFBE4F1), Color(0xFFB83280)),
  ];
}

/// Semantic design tokens exposed as a [ThemeExtension] so every widget gets
/// the right value for the current brightness.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.muted,
    required this.border,
    required this.primary,
    required this.primarySoft,
    required this.secondary,
    required this.secondarySoft,
    required this.emergency,
    required this.emergencySoft,
    required this.success,
    required this.warning,
    required this.info,
    required this.headerGradient,
    required this.isDark,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color text;
  final Color muted;
  final Color border;
  final Color primary;
  final Color primarySoft;
  final Color secondary;
  final Color secondarySoft;
  final Color emergency;
  final Color emergencySoft;
  final Color success;
  final Color warning;
  final Color info;
  final LinearGradient headerGradient;
  final bool isDark;

  static const light = AppPalette(
    background: AppColors.bgLight,
    surface: AppColors.surfaceLight,
    surfaceAlt: Color(0xFFF1F3F5),
    text: AppColors.textLight,
    muted: AppColors.mutedLight,
    border: AppColors.borderLight,
    primary: AppColors.primary,
    primarySoft: Color(0xFFE3F4EC),
    secondary: AppColors.secondary,
    secondarySoft: Color(0xFFFDEBDD),
    emergency: AppColors.emergency,
    emergencySoft: Color(0xFFFDE2E4),
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    headerGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primary, AppColors.teal],
    ),
    isDark: false,
  );

  static const dark = AppPalette(
    background: AppColors.bgDark,
    surface: AppColors.surfaceDark,
    surfaceAlt: AppColors.surfaceDark2,
    text: AppColors.textDark,
    muted: AppColors.mutedDark,
    border: AppColors.borderDark,
    primary: Color(0xFF3DBE8B),
    primarySoft: Color(0xFF15332A),
    secondary: AppColors.secondary,
    secondarySoft: Color(0xFF3A2A1C),
    emergency: Color(0xFFFF5A66),
    emergencySoft: Color(0xFF3B1A1E),
    success: Color(0xFF3CC1B2),
    warning: AppColors.warning,
    info: Color(0xFF6FA3C4),
    headerGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0A4F3A), Color(0xFF0E6B5D)],
    ),
    isDark: true,
  );

  /// Pastel pair for index [i]; in dark mode the background is a tinted
  /// version of the foreground so icons stay legible.
  (Color bg, Color fg) pastel(int i) {
    final (bg, fg) = AppColors.pastels[i % AppColors.pastels.length];
    if (!isDark) return (bg, fg);
    final lifted = Color.lerp(fg, Colors.white, 0.35)!;
    return (fg.withValues(alpha: 0.22), lifted);
  }

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }
}
