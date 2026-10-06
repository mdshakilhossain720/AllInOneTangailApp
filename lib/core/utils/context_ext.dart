import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Bilingual text for demo data.
class Tr {
  const Tr(this.en, this.bn);
  final String en;
  final String bn;

  String of(BuildContext context) => context.isBn ? bn : en;
}

const _bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

String toBanglaDigits(String input) {
  final b = StringBuffer();
  for (final c in input.codeUnits) {
    if (c >= 48 && c <= 57) {
      b.write(_bnDigits[c - 48]);
    } else {
      b.writeCharCode(c);
    }
  }
  return b.toString();
}

final _grouping = NumberFormat('#,##,##0', 'en_IN');

extension AppContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isBn => Localizations.localeOf(this).languageCode == 'bn';

  /// Converts any ASCII digits to Bangla digits when the UI is in Bangla.
  String digits(Object value) {
    final s = value.toString();
    return isBn ? toBanglaDigits(s) : s;
  }

  /// `৳1,25,000` style (South-Asian grouping), localized digits.
  String taka(num amount) => '৳${digits(_grouping.format(amount.round()))}';

  /// Compact count: 1.2k, 12k.
  String compact(num n) {
    final s = n >= 1000 ? '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k' : '$n';
    return digits(s);
  }

  String tr(Tr t) => t.of(this);

  /// Formats a time of day as 05:42 AM (localized digits).
  String clock(DateTime t) => digits(DateFormat('hh:mm a').format(t));

  String shortDate(DateTime d) => digits(DateFormat('d MMM yyyy', isBn ? 'bn' : 'en').format(d));

  void toast(String message, {String? actionLabel, VoidCallback? onAction}) {
    final m = ScaffoldMessenger.of(this);
    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        action: actionLabel == null ? null : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      ),
    );
  }
}
