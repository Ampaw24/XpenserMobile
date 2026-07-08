import 'package:expenser/models/account_model.dart';

abstract class IAccountRepository {
  List<AccountModel> getAll();
  AccountModel? getById(String id);
  Future<void> add(AccountModel account);
  Future<void> update(AccountModel account);
  Future<void> delete(String id);
}
