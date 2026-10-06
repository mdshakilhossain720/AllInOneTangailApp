// End-to-end UI flows on the demo data (no network).
import 'package:allinonetangail/app.dart';
import 'package:allinonetangail/core/router/app_router.dart';
import 'package:allinonetangail/core/state/providers.dart';
import 'package:allinonetangail/core/utils/test_mode.dart';
import 'package:allinonetangail/features/shell/app_shell.dart';
import 'package:allinonetangail/features/shell/sos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<ProviderContainer> _launch(WidgetTester tester, String route, {Size size = const Size(400, 860)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const TangailApp()));
  container.read(routerProvider).go(route);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  return container;
}

/// Unmounts and flushes timers so pending demo delays don't fail the test.
Future<void> _finish(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 3));
}

void main() {
  setUpAll(() => UiTestMode.enabled = true);

  testWidgets('bottom nav switches tabs; tablet uses NavigationRail', (tester) async {
    await _launch(tester, '/home');
    expect(find.byType(AnimatedBottomNav), findsOneWidget);
    expect(tester.getSize(find.byType(AnimatedBottomNav)).height, lessThan(120));
    await tester.tap(find.bySemanticsLabel('Shop'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Search sarees, sweets, electronics…'), findsOneWidget);
    await _finish(tester);

    await _launch(tester, '/home', size: const Size(1280, 800));
    expect(find.byType(NavigationRail), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('SOS tap opens sheet; 2s hold opens 999 countdown that can be cancelled', (tester) async {
    await _launch(tester, '/home');
    final sos = find.byType(SosButton);
    await tester.tap(sos);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Emergency help'), findsOneWidget);
    Navigator.of(tester.element(find.text('Emergency help'))).pop();
    await tester.pump(const Duration(seconds: 1));

    final gesture = await tester.startGesture(tester.getCenter(sos));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Calling 999'), findsOneWidget);
    await gesture.up();
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Calling 999'), findsNothing);
    expect(find.text('Emergency call cancelled'), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('add to cart flies to cart and increments the badge', (tester) async {
    final c = await _launch(tester, '/shop/product/p1');
    final before = c.read(cartCountProvider);
    await tester.tap(find.text('Add to cart'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(c.read(cartCountProvider), before + 1);
    expect(find.text('Added to cart'), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('checkout steps through to the order success screen', (tester) async {
    final c = await _launch(tester, '/checkout');
    final ordersBefore = c.read(ordersProvider).length;
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.tap(find.text('Place order'));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Order placed!'), findsOneWidget);
    expect(c.read(ordersProvider).length, ordersBefore + 1);
    expect(c.read(cartProvider).where((e) => e.selected), isEmpty);
    await _finish(tester);
  });

  testWidgets('language switch shows Bangla text and digits; offline banner toggles', (tester) async {
    final c = await _launch(tester, '/settings');
    await tester.tap(find.text('বাংলা'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('সেটিংস'), findsWidgets);

    c.read(offlineProvider.notifier).set(true);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('আপনি অফলাইনে আছেন — সংরক্ষিত তথ্য দেখানো হচ্ছে'), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('wishlist heart toggles saved products', (tester) async {
    final c = await _launch(tester, '/shop/product/p5');
    expect(c.read(wishlistProvider).contains('p5'), isFalse);
    await tester.tap(find.bySemanticsLabel('Wishlist').first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(c.read(wishlistProvider).contains('p5'), isTrue);
    await _finish(tester);
  });
}
