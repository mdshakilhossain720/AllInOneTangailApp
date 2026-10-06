// Generates lib/l10n/app_en.arb and app_bn.arb from tool/strings.txt.
//
// Each non-empty, non-comment line of strings.txt is: key|English|Bangla
// Placeholders such as {name} are detected automatically.
//
// Run: dart run tool/gen_arb.dart && flutter gen-l10n
import 'dart:convert';
import 'dart:io';

void main() {
  final lines = File('tool/strings.txt').readAsLinesSync();
  final en = <String, Object>{'@@locale': 'en'};
  final bn = <String, Object>{'@@locale': 'bn'};
  final placeholder = RegExp(r'\{(\w+)\}');
  final seen = <String>{};

  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final parts = line.split('|');
    if (parts.length != 3) {
      stderr.writeln('Bad line: $line');
      exit(1);
    }
    final key = parts[0].trim();
    if (!seen.add(key)) {
      stderr.writeln('Duplicate key: $key');
      exit(1);
    }
    en[key] = parts[1].trim();
    bn[key] = parts[2].trim();
    final names = placeholder.allMatches(parts[1]).map((m) => m.group(1)!).toSet();
    if (names.isNotEmpty) {
      en['@$key'] = {
        'placeholders': {for (final n in names) n: {'type': 'String'}},
      };
    }
  }

  const encoder = JsonEncoder.withIndent('  ');
  File('lib/l10n/app_en.arb').writeAsStringSync('${encoder.convert(en)}\n');
  File('lib/l10n/app_bn.arb').writeAsStringSync('${encoder.convert(bn)}\n');
  stdout.writeln('Wrote ${seen.length} keys.');
}
