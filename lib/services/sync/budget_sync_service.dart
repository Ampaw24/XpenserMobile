import 'dart:async';

import 'package:expenser/data/repositories/budget_outbox_repository.dart';
import 'package:expenser/data/repositories/budget_repository.dart';
import 'package:expenser/data/repositories/interfaces/i_budget_repository.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/services/firebase_user_data_service.dart';
import 'package:expenser/services/sync/budget_remote_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase is the source of truth for budgets; Hive holds an offline copy.
///
/// Every change is written to the offline copy and to a durable outbox, then
/// sent to Firebase. The outbox entry is cleared only once Firebase confirms,
/// and unconfirmed changes are re-sent on reconnect or next launch.
class BudgetSyncService {
  BudgetSyncService({
    required BudgetRemoteSource remote,
    required IBudgetRepository cache,
    required BudgetOutboxRepository outbox,
  }) : _remote = remote,
       _cache = cache,
       _outbox = outbox;

  final BudgetRemoteSource _remote;
  final IBudgetRepository _cache;
  final BudgetOutboxRepository _outbox;

  Future<void> save(String? uid, BudgetModel budget) async {
    await _cache.add(budget);
    if (uid == null) return;
    _send(uid, await _outbox.put(uid, budget.id, budget));
  }

  Future<void> delete(String? uid, String id) async {
    await _cache.delete(id);
    if (uid == null) return;
    _send(uid, await _outbox.put(uid, id, null));
  }

  /// Re-sends every change Firebase hasn't confirmed yet.
  void flush(String uid) {
    for (final change in _outbox.pendingFor(uid)) {
      _send(uid, change);
    }
  }

  /// Replaces the offline copy with the server's list, keeping local changes
  /// that haven't reached the server yet.
  Future<void> applyRemote(String uid, List<BudgetModel> remote) async {
    final merged = {for (final b in remote) b.id: b};

    // One-time upgrade: budgets saved before Firebase became the source of
    // truth may never have reached it. Queue them instead of dropping them.
    if (!_outbox.isMigrated(uid)) {
      for (final local in _cache.getAll()) {
        if (!merged.containsKey(local.id)) {
          merged[local.id] = local;
          _send(uid, await _outbox.put(uid, local.id, local));
        }
      }
      await _outbox.markMigrated(uid);
    }

    for (final change in _outbox.pendingFor(uid)) {
      final budget = change.budget;
      if (budget == null) {
        merged.remove(change.id);
      } else {
        merged[change.id] = budget;
      }
    }
    await _cache.replaceAll(merged.values.toList());
  }

  void _send(String uid, PendingBudgetChange change) {
    final budget = change.budget;
    final request =
        budget == null
            ? _remote.deleteBudget(uid, change.id)
            : _remote.saveBudget(uid, budget);
    request
        .then((_) => _outbox.confirm(uid, change))
        .catchError((Object e) => debugPrint('Budget sync pending: $e'));
  }
}

final budgetRemoteSourceProvider = Provider<BudgetRemoteSource>(
  (ref) => ref.watch(firebaseUserDataServiceProvider),
);

final budgetSyncServiceProvider = Provider<BudgetSyncService>(
  (ref) => BudgetSyncService(
    remote: ref.watch(budgetRemoteSourceProvider),
    cache: ref.watch(budgetRepositoryProvider),
    outbox: ref.watch(budgetOutboxRepositoryProvider),
  ),
);
