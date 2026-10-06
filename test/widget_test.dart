import 'package:allinonetangail/core/responsive/responsive.dart';
import 'package:allinonetangail/core/utils/context_ext.dart';
import 'package:allinonetangail/data/demo/services_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converts ASCII digits to Bangla digits', () {
    expect(toBanglaDigits('৳1,250 at 05:42'), '৳১,২৫০ at ০৫:৪২');
  });

  test('breakpoints map widths to sizes', () {
    expect(AppBreakpoints.of(320), ScreenSize.compact);
    expect(AppBreakpoints.of(390), ScreenSize.phone);
    expect(AppBreakpoints.of(700), ScreenSize.largePhone);
    expect(AppBreakpoints.of(1024), ScreenSize.tablet);
  });

  test('grid columns adapt to width', () {
    expect(<double>[320, 420, 700, 1000].map(AppBreakpoints.categoryColumns), [4, 5, 6, 8]);
    expect(<double>[320, 700, 1000].map(AppBreakpoints.productColumns), [2, 3, 4]);
  });

  test('next prayer rolls over to tomorrow after Isha', () {
    final late = DateTime(2026, 10, 6, 23, 30);
    final next = nextPrayer(late);
    expect(next.key, 'fajr');
    expect(next.time.day, 7);
  });
}
