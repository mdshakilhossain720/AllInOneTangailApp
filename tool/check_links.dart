// Checks that every literal in-app path ('/…') used in lib/ matches a route
// registered in lib/core/router/app_router.dart.
//
// Run: dart run tool/check_links.dart
import 'dart:io';

void main() {
  final router = File('lib/core/router/app_router.dart').readAsStringSync();
  final routes = RegExp(r"(?:_page\(\s*|path: )'(/[^']*)'")
      .allMatches(router)
      .map((m) => m.group(1)!)
      .toSet();
  final patterns = [
    for (final r in routes) RegExp('^${r.replaceAll(RegExp(r':\w+'), r'[^/]+')}\$'),
  ];

  final link = RegExp(r"""['"](/(?:[a-z\-]+)(?:/[^'"\s]*)?)['"]""");
  final bad = <String>{};
  var checked = 0;
  for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.dart') || f.path.contains('l10n') || f.path.endsWith('app_router.dart')) continue;
    for (final m in link.allMatches(f.readAsStringSync())) {
      var path = m.group(1)!.split('?').first.replaceAll(RegExp(r'\$\{[^}]*\}|\$\w+'), 'X');
      if (path.contains('.') || path.startsWith('//')) continue; // URLs, assets
      checked++;
      if (!patterns.any((p) => p.hasMatch(path))) bad.add('$path  (${f.path})');
    }
  }
  for (final b in bad) {
    stdout.writeln('UNMATCHED: $b');
  }
  stdout.writeln('Checked $checked links against ${routes.length} routes; ${bad.length} unmatched.');
  if (bad.isNotEmpty) exitCode = 1;
}
