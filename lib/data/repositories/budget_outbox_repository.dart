import 'dart:convert';

import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A budget change the server hasn't confirmed yet. [budget] is null for a
/// delete. [encoded] identifies this exact change so a late confirmation of
/// an older write can't clear a newer one.
class PendingBudgetChange {
  const PendingBudgetChange(this.id, this.budget, this.encoded);

  final String id;
  final BudgetModel? budget;
  final String encoded;
}

/// Durable queue of unsynced budget changes, keyed per user so one account's
/// pending edits are never sent to another account.
class BudgetOutboxRepository {
  Box<String> get _box => HiveService.box<String>(HiveService.budgetOutbox);

  static String _key(String uid, String id) => '$uid|$id';
  static String _migratedKey(String uid) => '$uid|#migrated';

  /// Records the latest change for [id], replacing any older pending one.
  Future<PendingBudgetChange> put(
    String uid,
    String id,
    BudgetModel? budget,
  ) async {
    final encoded = jsonEncode({
      'savedAt': DateTime.now().microsecondsSinceEpoch,
      'budget': budget?.toMap(),
    });
    await _box.put(_key(uid, id), encoded);
    return PendingBudgetChange(id, budget, encoded);
  }

  List<PendingBudgetChange> pendingFor(String uid) {
    final prefix = '$uid|';
    final changes = <PendingBudgetChange>[];
    for (final key in _box.keys.cast<String>()) {
      if (!key.startsWith(prefix) || key == _migratedKey(uid)) continue;
      final encoded = _box.get(key)!;
      final data = jsonDecode(encoded) as Map<String, dynamic>;
      final map = data['budget'] as Map<String, dynamic>?;
      changes.add(
        PendingBudgetChange(
          key.substring(prefix.length),
          map == null ? null : BudgetModel.fromMap(map),
          encoded,
        ),
      );
    }
    return changes;
  }

  /// Drops [change] once confirmed, unless a newer change replaced it.
  Future<void> confirm(String uid, PendingBudgetChange change) async {
    final key = _key(uid, change.id);
    if (_box.get(key) == change.encoded) await _box.delete(key);
  }

  bool isMigrated(String uid) => _box.containsKey(_migratedKey(uid));

  Future<void> markMigrated(String uid) => _box.put(_migratedKey(uid), '1');
}

final budgetOutboxRepositoryProvider = Provider<BudgetOutboxRepository>(
  (_) => BudgetOutboxRepository(),
);
