import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/models/account_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AccountRepository {
  Box<AccountModel> get _box =>
      HiveService.box<AccountModel>(HiveService.accounts);

  List<AccountModel> getAll() => _box.values.toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  AccountModel? getById(String id) => _box.get(id);

  Future<void> add(AccountModel a) => _box.put(a.id, a);

  Future<void> update(AccountModel a) => _box.put(a.id, a);

  Future<void> delete(String id) => _box.delete(id);
}

final accountRepositoryProvider =
    Provider<AccountRepository>((ref) => AccountRepository());
