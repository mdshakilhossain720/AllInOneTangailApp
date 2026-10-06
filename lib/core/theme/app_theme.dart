import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'tokens.dart';
import '../utils/test_mode.dart';

abstract final class AppTheme {
  /// Bangla UI uses Hind Siliguri (which also covers Latin); English UI uses
  /// Poppins with Hind Siliguri as fallback for any Bangla content.
  static ThemeData build({required Brightness brightness, required bool bangla}) {
    final isDark = brightness == Brightness.dark;
    final p = isDark ? AppPalette.dark : AppPalette.light;

    TextStyle font(double size, FontWeight weight) {
      final base = TextStyle(fontSize: size, fontWeight: weight, height: TypeScale.lineHeight, color: p.text);
      if (UiTestMode.enabled) return base;
      if (bangla) return GoogleFonts.hindSiliguri(textStyle: base);
      final fallback = GoogleFonts.hindSiliguri(fontWeight: weight).fontFamily;
      return GoogleFonts.poppins(textStyle: base).copyWith(fontFamilyFallback: [?fallback]);
    }

    final textTheme = TextTheme(
      displayLarge: font(34, FontWeight.w700),
      displayMedium: font(30, FontWeight.w700),
      displaySmall: font(TypeScale.display, FontWeight.w700),
      headlineLarge: font(24, FontWeight.w700),
      headlineMedium: font(TypeScale.h1, FontWeight.w700),
      headlineSmall: font(20, FontWeight.w600),
      titleLarge: font(TypeScale.h2, FontWeight.w600),
      titleMedium: font(TypeScale.title, FontWeight.w600),
      titleSmall: font(TypeScale.body, FontWeight.w600),
      bodyLarge: font(TypeScale.title, FontWeight.w400),
      bodyMedium: font(TypeScale.body, FontWeight.w400),
      bodySmall: font(TypeScale.caption, FontWeight.w400).copyWith(color: p.muted),
      labelLarge: font(TypeScale.body, FontWeight.w600),
      labelMedium: font(TypeScale.caption, FontWeight.w500),
      labelSmall: font(11, FontWeight.w500),
    );

    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: brightness).copyWith(
      primary: p.primary,
      onPrimary: Colors.white,
      secondary: p.secondary,
      onSecondary: const Color(0xFF3B2410),
      error: p.emergency,
      surface: p.surface,
      onSurface: p.text,
      onSurfaceVariant: p.muted,
      outline: p.border,
      outlineVariant: p.border,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surfaceAlt,
      surfaceContainerHigh: p.surfaceAlt,
      surfaceContainerHighest: p.surfaceAlt,
    );

    final buttonShape = RoundedRectangleBorder(borderRadius: Radii.buttonBorder);
    const minButton = Size(48, 48);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      textTheme: textTheme,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      appBarTheme: AppBarThemeData(
        backgroundColor: p.background,
        foregroundColor: p.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardBorder,
          side: isDark ? BorderSide(color: p.border) : BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: minButton,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: Gap.xl, vertical: Gap.md),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: minButton, shape: buttonShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minButton,
          shape: buttonShape,
          foregroundColor: p.primary,
          side: BorderSide(color: p.border),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: minButton,
          shape: buttonShape,
          foregroundColor: p.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: minButton)),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: isDark ? p.surfaceAlt : p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(color: p.muted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: p.muted),
        border: OutlineInputBorder(
          borderRadius: Radii.buttonBorder,
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.buttonBorder,
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.buttonBorder,
          borderSide: BorderSide(color: p.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Radii.buttonBorder,
          borderSide: BorderSide(color: p.emergency),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: Radii.chipBorder),
        side: BorderSide(color: p.border),
        backgroundColor: p.surface,
        selectedColor: p.primarySoft,
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
        showCheckmark: false,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.border,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sheet)),
        titleTextStyle: textTheme.titleLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? p.surfaceAlt : p.text,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: Radii.buttonBorder),
        actionTextColor: p.secondary,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.primary,
        unselectedLabelColor: p.muted,
        indicatorColor: p.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        dividerColor: p.border,
        tabAlignment: TabAlignment.start,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.primarySoft,
        selectedIconTheme: IconThemeData(color: p.primary),
        unselectedIconTheme: IconThemeData(color: p.muted),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: p.primary),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: p.muted),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.muted,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
        minTileHeight: 56,
      ),
      checkboxTheme: CheckboxThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
      // Shared-axis (horizontal) transitions for every pushed page.
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: SharedAxisPageTransitionsBuilder(
              transitionType: SharedAxisTransitionType.horizontal,
              fillColor: p.background,
            ),
        },
      ),
    );
  }
}
