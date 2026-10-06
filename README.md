# Tangail All in One — UI demo

A responsive Flutter UI for a local super app for Tangail district, Bangladesh:
emergency services, local directory, transport, news and a community
marketplace. **UI only.** All data is static demo data in `lib/data/demo/`, and
every action ends in a realistic UI response: a snackbar, sheet, dialog or
success screen.

## Run

```sh
flutter pub get
flutter run            # any device; `-d chrome` works too
```

Requires Flutter 3.47 / Dart 3.13. On Windows, building for Android or desktop
(which use plugins) needs **Developer Mode** turned on for symlink support. Web
builds do not.

The app starts at the splash screen, then onboarding → phone login → OTP (any 6
digits) → upazila picker → Home.

Demo switches are in **Profile → Settings**:
- Language: বাংলা / English
- Theme: light / dark / system
- **Simulate offline**: shows the offline banner

## Stack

- **material_ui**: Flutter 3.47 moved Material out of the SDK. The app imports
  `package:material_ui/material_ui.dart`, not `package:flutter/material.dart`,
  because go_router, shimmer and cached_network_image already use it.
- **Riverpod 3** for state (cart, wishlist, saved items, theme, language,
  orders, seller products) and **go_router** for navigation (a
  `StatefulShellRoute` holds the 5 tabs).
- google_fonts (Hind Siliguri for Bangla, Poppins for English), fl_chart,
  flutter_map with OpenStreetMap tiles, shimmer, confetti, and animations
  (shared-axis and fade-through transitions).

## Structure

```
lib/
  core/       theme (tokens, AppPalette ThemeExtension), responsive
              (AppBreakpoints, ResponsiveLayout), router, Riverpod state,
              utils (Bangla digits, ৳ formatting)
  data/       models + demo data (12 real upazilas, dummy 01700-… numbers)
  widgets/    reusable component library (see widgets.dart)
  features/   auth · shell (nav, SOS, offline banner) · home · search ·
              explore/{health,legal,travel,business,daily,community} ·
              shop · seller · saved · profile
  l10n/       generated ARB files + AppLocalizations
tool/
  strings.txt       source of all UI strings (key|English|Bangla)
  gen_arb.dart      strings.txt → app_en.arb / app_bn.arb
  check_links.dart  every in-app path must match a registered route
  check_screens.sh  runs the rendering harness, prints failures only
```

To add or change a string, edit `tool/strings.txt`, then run:

```sh
dart run tool/gen_arb.dart && flutter gen-l10n
```

## Responsiveness

The breakpoints are compact < 360, phone 360–599, large phone 600–839, and
tablet ≥ 840.
- Category grids use 4 → 5 → 6 → 8 columns; product grids use 2 → 3 → 4.
- On tablets, a NavigationRail replaces the bottom nav.
- Doctors, lawyers, businesses and product listings use a master-detail
  layout on tablets.

## Tests

```sh
flutter test                 # 330 tests
./tool/check_screens.sh      # rendering harness only, filtered output
dart run tool/check_links.dart
```

`test/screens_test.dart` renders all 80 routes in 4 variants and scrolls
through each page:
- 320 px wide at 1.3× text
- Bangla in dark mode
- tablet
- phone landscape

Any overflow, exception, unregistered route or full-screen bottom bar fails
the test. `test/flows_test.dart` covers these key interactions:
- SOS tap and the 2 s hold → 999 countdown → cancel
- fly-to-cart
- checkout through to order success
- language switch and offline banner
- wishlist
- tablet NavigationRail

The tests run with system fonts and placeholder images (`UiTestMode`) because
font and image downloads aren't available in the test environment.
