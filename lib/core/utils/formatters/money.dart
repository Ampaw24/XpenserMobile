import 'package:intl/intl.dart';

/// e.g. "GHS 1,250.00". Amounts are shown with their ISO currency code.
String formatMoney(double amount, String currencyCode) => NumberFormat.currency(
  symbol: '$currencyCode ',
  decimalDigits: 2,
).format(amount);
