import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router/app_router.dart';
import 'core/state/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/offline_banner.dart';
import 'l10n/app_localizations.dart';

class TangailApp extends ConsumerWidget {
  const TangailApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final bangla = locale.languageCode == 'bn';
    return MaterialApp.router(
      title: 'Tangail All in One',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      themeMode: ref.watch(themeModeProvider),
      theme: AppTheme.build(brightness: Brightness.light, bangla: bangla),
      darkTheme: AppTheme.build(brightness: Brightness.dark, bangla: bangla),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      builder: (context, child) => OfflineBannerHost(child: child!),
    );
  }
}
