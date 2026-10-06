// Renders every route at small-phone, large-text, Bangla and tablet sizes,
// scrolling through each page. Any RenderFlex overflow or exception fails.
import 'package:allinonetangail/app.dart';
import 'package:allinonetangail/core/router/app_router.dart';
import 'package:allinonetangail/core/state/providers.dart';
import 'package:allinonetangail/core/utils/test_mode.dart';
import 'package:allinonetangail/features/shell/app_shell.dart';
import 'package:allinonetangail/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'routes.dart';

class _Variant {
  const _Variant(this.name, this.size, {this.textScale = 1.0, this.bangla = false, this.dark = false});
  final String name;
  final Size size;
  final double textScale;
  final bool bangla;
  final bool dark;
}

const _variants = [
  _Variant('320 en x1.3', Size(320, 640), textScale: 1.3),
  _Variant('360 bn dark', Size(360, 740), bangla: true, dark: true),
  _Variant('tablet en', Size(1280, 800)),
  _Variant('landscape en', Size(780, 360)),
];

void main() {
  setUpAll(() => UiTestMode.enabled = true);

  for (final route in allRoutes) {
    for (final v in _variants) {
      testWidgets('$route @ ${v.name}', (tester) async {
        tester.view.physicalSize = v.size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = v.textScale;
        tester.platformDispatcher.platformBrightnessTestValue = v.dark ? Brightness.dark : Brightness.light;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);

        final container = ProviderContainer();
        addTearDown(container.dispose);
        if (v.bangla) container.read(localeProvider.notifier).set(const Locale('bn'));

        await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const TangailApp()));
        container.read(routerProvider).go(route);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 900));

        expect(find.byIcon(Icons.construction_rounded), findsNothing, reason: 'route not registered: $route');

        // Bottom bars must hug their content (loose constraints can make
        // Align/Center-based bars fill the whole screen).
        for (final bar in [...find.byType(StickyBar).evaluate(), ...find.byType(AnimatedBottomNav).evaluate()]) {
          expect(bar.size!.height, lessThan(v.size.height * 0.4), reason: 'bottom bar too tall on $route');
        }

        // Scroll through the page to build everything below the fold.
        for (var i = 0; i < 4; i++) {
          await tester.dragFrom(Offset(v.size.width / 2, v.size.height * 0.75), Offset(0, -v.size.height * 0.6));
          await tester.pump(const Duration(milliseconds: 300));
        }
        // Let delayed demo loaders / splash timers finish, then unmount so
        // periodic timers are cancelled.
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 3));
      });
    }
  }
}
