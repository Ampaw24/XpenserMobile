import 'package:expenser/models/account_model.dart';

enum TransferError {
  missingDestination('Choose the account to transfer to.'),
  sameAccount('Choose a different account to transfer to.'),
  currencyMismatch(
    'Both accounts must use the same currency. '
    'Transfers between currencies are not supported yet.',
  );

  const TransferError(this.message);

  final String message;
}

/// Returns why moving money from [from] to [to] is not allowed, or null.
///
/// Cross-currency transfers are rejected so balances never depend on an
/// indicative exchange rate.
TransferError? validateTransfer({
  required AccountModel from,
  required AccountModel? to,
}) {
  if (to == null) return TransferError.missingDestination;
  if (to.id == from.id) return TransferError.sameAccount;
  if (to.currencyCode != from.currencyCode) {
    return TransferError.currencyMismatch;
  }
  return null;
}
