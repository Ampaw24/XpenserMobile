import 'dart:async';
import 'dart:io';

import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/data/repositories/budget_outbox_repository.dart';
import 'package:expenser/data/repositories/budget_repository.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/services/sync/budget_remote_source.dart';
import 'package:expenser/services/sync/budget_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Server stand-in. While [online] is false, requests stay pending like
/// Firebase writes made without a connection.
class _FakeRemote implements BudgetRemoteSource {
  bool online = true;
  final saved = <String, BudgetModel>{};
  final deleted = <String>[];
  final _pending = <(Completer<void>, void Function())>[];

  Future<void> _request(void Function() apply) {
    if (online) {
      apply();
      return Future.value();
    }
    final completer = Completer<void>();
    _pending.add((completer, apply));
    return completer.future;
  }

  /// Simulates the app being killed while offline: queued requests are lost.
  void dropPending() => _pending.clear();

  @override
  Future<void> saveBudget(String uid, BudgetModel budget) =>
      _request(() => saved['$uid/${budget.id}'] = budget);

  @override
  Future<void> deleteBudget(String uid, String id) =>
      _request(() => deleted.add('$uid/$id'));

  @override
  Stream<List<BudgetModel>> watchBudgets(String uid) => const Stream.empty();

  @override
  Stream<bool> watchConnection() => const Stream.empty();
}

void main() {
  late Directory dir;
  late _FakeRemote remote;
  late BudgetRepository cache;
  late BudgetOutboxRepository outbox;
  late BudgetSyncService sync;

  BudgetModel budget(String id, {double limit = 100}) => BudgetModel(
    id: id,
    categoryId: 'food',
    limitAmount: limit,
    month: 11,
    year: 2026,
    createdAt: DateTime(2026, 11, 1),
    planId: 'plan',
  );

  setUpAll(() => Hive.registerAdapter(BudgetModelAdapter()));

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('budget_sync');
    Hive.init(dir.path);
    await Hive.openBox<BudgetModel>(HiveService.budgets);
    await Hive.openBox<String>(HiveService.budgetOutbox);
    remote = _FakeRemote();
    cache = BudgetRepository();
    outbox = BudgetOutboxRepository();
    sync = BudgetSyncService(remote: remote, cache: cache, outbox: outbox);
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('a confirmed save is cached and leaves nothing pending', () async {
    await sync.save('u1', budget('b1'));
    await settle();

    expect(cache.getById('b1'), isNotNull);
    expect(remote.saved.keys, ['u1/b1']);
    expect(outbox.pendingFor('u1'), isEmpty);
  });

  test('offline changes survive a restart and are sent on reconnect', () async {
    remote.online = false;
    await sync.save('u1', budget('b1'));
    await sync.delete('u1', 'b2');
    remote.dropPending();

    expect(
      outbox.pendingFor('u1').map((c) => c.id),
      unorderedEquals(['b1', 'b2']),
    );

    remote.online = true;
    sync.flush('u1');
    await settle();

    expect(remote.saved.keys, ['u1/b1']);
    expect(remote.deleted, ['u1/b2']);
    expect(outbox.pendingFor('u1'), isEmpty);
  });

  test(
    'server data replaces the offline copy except unsent local changes',
    () async {
      await outbox.markMigrated('u1');
      await cache.add(budget('stale'));
      remote.online = false;
      await sync.save('u1', budget('local-edit', limit: 999));
      await sync.delete('u1', 'local-delete');

      await sync.applyRemote('u1', [
        budget('server-only'),
        budget('local-edit', limit: 1),
        budget('local-delete'),
      ]);

      final ids = cache.getAll().map((b) => b.id).toSet();
      expect(ids, {'server-only', 'local-edit'});
      expect(cache.getById('local-edit')!.limitAmount, 999);
    },
  );

  test('first sync uploads budgets that only existed on this phone', () async {
    await cache.add(budget('never-uploaded'));

    await sync.applyRemote('u1', [budget('on-server')]);
    await settle();

    expect(cache.getAll().map((b) => b.id).toSet(), {
      'never-uploaded',
      'on-server',
    });
    expect(remote.saved.keys, ['u1/never-uploaded']);
  });

  test("one user's pending changes are never sent for another user", () async {
    remote.online = false;
    await sync.save('alice', budget('b1'));
    remote.dropPending();
    remote.online = true;

    sync.flush('bob');
    await settle();

    expect(remote.saved, isEmpty);
    expect(outbox.pendingFor('alice').single.id, 'b1');
  });
}
