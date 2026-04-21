import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/data/repositories/interfaces/i_account_repository.dart';
import 'package:expenser/models/account_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AccountRepository implements IAccountRepository {
  Box<AccountModel> get _box =>
      HiveService.box<AccountModel>(HiveService.accounts);

  @override
  List<AccountModel> getAll() => _box.values.toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  @override
  AccountModel? getById(String id) => _box.get(id);

  @override
  Future<void> add(AccountModel account) => _box.put(account.id, account);

  @override
  Future<void> update(AccountModel account) => _box.put(account.id, account);

  @override
  Future<void> delete(String id) => _box.delete(id);
}

final accountRepositoryProvider =
    Provider<IAccountRepository>((ref) => AccountRepository());
