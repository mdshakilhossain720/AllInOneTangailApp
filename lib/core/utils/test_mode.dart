/// Set by widget tests: avoids runtime font downloads and network images,
/// which aren't available in the test environment.
abstract final class UiTestMode {
  static bool enabled = false;
}
