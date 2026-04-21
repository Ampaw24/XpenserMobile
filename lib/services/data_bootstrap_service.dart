import 'package:expenser/data/repositories/interfaces/i_account_repository.dart';
import 'package:expenser/data/repositories/interfaces/i_category_repository.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/account_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expenser/data/repositories/account_repository.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:uuid/uuid.dart';

class DataBootstrapService {
  DataBootstrapService({
    required IAccountRepository accountRepository,
    required ICategoryRepository categoryRepository,
  })  : _accountRepo = accountRepository,
        _categoryRepo = categoryRepository;

  final IAccountRepository _accountRepo;
  final ICategoryRepository _categoryRepo;

  Future<void> seedIfNeeded(String currency) async {
    if (_categoryRepo.isEmpty) {
      await _categoryRepo.seedDefaults();
    }
    if (_accountRepo.getAll().isEmpty) {
      await _accountRepo.add(AccountModel(
        id: const Uuid().v4(),
        name: 'Cash',
        type: AccountType.cash,
        initialBalance: 0.0,
        currencyCode: currency,
        colorHex: 'FF4CAF50',
        iconCodePoint: Icons.wallet_rounded.codePoint,
        createdAt: DateTime.now(),
      ));
    }
  }
}

final dataBootstrapServiceProvider = Provider<DataBootstrapService>((ref) {
  return DataBootstrapService(
    accountRepository: ref.read(accountRepositoryProvider),
    categoryRepository: ref.read(categoryRepositoryProvider),
  );
});
