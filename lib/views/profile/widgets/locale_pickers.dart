import 'package:expenser/core/constants/countries.dart';
import 'package:expenser/core/utils/widgets/app_option_sheet.dart';
import 'package:flutter/material.dart';

/// Country names per currency, so currency search also matches "Ghana".
final Map<String, String> _currencyCountries = () {
  final names = <String, List<String>>{};
  for (final c in countries) {
    names.putIfAbsent(c.currencyCode, () => []).add(c.name);
  }
  return {for (final e in names.entries) e.key: e.value.join(', ')};
}();

Future<Country?> pickCountry(BuildContext context, {String? selected}) async {
  final code = await showAppOptionSheet<String>(
    context,
    title: 'Country',
    selected: selected,
    searchable: true,
    options: [
      for (final c in countries)
        AppSelectOption(value: c.code, label: c.name, subtitle: c.currencyCode),
    ],
  );
  return countryByCode(code);
}

Future<String?> pickCurrency(BuildContext context, {String? selected}) {
  return showAppOptionSheet<String>(
    context,
    title: 'Currency',
    selected: selected,
    searchable: true,
    options: [
      for (final code in countryCurrencyCodes)
        AppSelectOption(
          value: code,
          label: code,
          subtitle: _currencyCountries[code],
        ),
    ],
  );
}
