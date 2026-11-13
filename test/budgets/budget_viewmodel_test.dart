import 'dart:io';

import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/data/repositories/notification_repository.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/account_type.dart';
import 'package:expenser/models/app_settings_model.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/budget_period.dart';
import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/notification_record.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/services/notification/budget_alert_service.dart';
import 'package:expenser/services/notification/fcm_service.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Records alerts instead of touching platform notification APIs.
class _FakeFcmService implements FcmService {
  _FakeFcmService(this._repo);

  final NotificationRepository _repo;
  final sent = <String>[];

  @override
  Future<void> showLocalNotification({
    required String title,
    required String body,
    required String type,
    String? route,
    String? id,
  }) async {
    sent.add(id!);
    await _repo.add(
      NotificationRecord(
        id: id,
        title: title,
        body: body,
        type: type,
        route: route,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory dir;
  late ProviderContainer container;
  late _FakeFcmService fcm;

  final now = DateTime.now();
  final thisMonth = BudgetDateRange.forPeriod(BudgetPeriodType.monthly, now);
  final inRange = thisMonth.start.add(const Duration(hours: 12));

  setUpAll(() {
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(AccountTypeAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(AccountModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(AppSettingsModelAdapter());
    Hive.registerAdapter(NotificationRecordAdapter());
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('budget_test');
    Hive.init(dir.path);
    await Hive.openBox<TransactionModel>(HiveService.transactions);
    await Hive.openBox<AccountModel>(HiveService.accounts);
    await Hive.openBox<CategoryModel>(HiveService.categories);
    await Hive.openBox<BudgetModel>(HiveService.budgets);
    await Hive.openBox<AppSettingsModel>(HiveService.settings);
    await Hive.openBox<NotificationRecord>(HiveService.notifications);
    await Hive.openBox<String>(HiveService.budgetOutbox);

    for (final a in [('acc-ghs', 'GHS'), ('acc-usd', 'USD')]) {
      await Hive.box<AccountModel>(HiveService.accounts).put(
        a.$1,
        AccountModel(
          id: a.$1,
          name: a.$1,
          type: AccountType.cash,
          initialBalance: 0,
          currencyCode: a.$2,
          colorHex: 'FF0F766E',
          iconCodePoint: 0xe041,
          createdAt: now,
        ),
      );
    }

    fcm = _FakeFcmService(NotificationRepository());
    container = ProviderContainer(
      overrides: [fcmServiceProvider.overrideWithValue(fcm)],
    );
  });

  tearDown(() async {
    container.dispose();
    await Hive.close();
    await dir.delete(recursive: true);
  });

  Future<void> addExpense(
    String id,
    double amount, {
    String category = 'food',
    String account = 'acc-ghs',
    DateTime? date,
    TransactionType type = TransactionType.expense,
  }) => container
      .read(transactionProvider.notifier)
      .addTransaction(
        TransactionModel(
          id: id,
          amount: amount,
          type: type,
          categoryId: category,
          accountId: account,
          date: date ?? inRange,
          createdAt: now,
        ),
      );

  BudgetModel allocation(
    String id,
    String category,
    double limit, {
    String planId = 'plan',
    BudgetDateRange? range,
    String period = 'monthly',
  }) {
    final r = range ?? thisMonth;
    return BudgetModel(
      id: id,
      categoryId: category,
      limitAmount: limit,
      month: r.start.month,
      year: r.start.year,
      createdAt: now,
      accountId: 'acc-ghs',
      period: period,
      planId: planId,
      startDate: r.start,
      endDate: r.end,
    );
  }

  BudgetNotifier notifier() => container.read(budgetProvider.notifier);
  BudgetPlan plan([String id = 'plan']) =>
      container.read(budgetProvider).planById(id)!;

  test(
    'counts only expenses in the plan account, categories and dates',
    () async {
      await notifier().savePlan('plan', [allocation('b-food', 'food', 200)]);

      await addExpense('t1', 50);
      await addExpense('t2', 30, account: 'acc-usd');
      await addExpense(
        't3',
        20,
        date: thisMonth.start.subtract(const Duration(hours: 1)),
      );
      await addExpense('t4', 40, category: 'rent');
      await addExpense('t5', 99, type: TransactionType.income);

      final p = plan();
      expect(p.totalSpent, 50);
      expect(p.currency, 'GHS');
      expect(p.usage, 0.25);
      expect(
        container.read(budgetPlanTransactionsProvider('plan')).map((t) => t.id),
        ['t1'],
      );
    },
  );

  test(
    'editing keeps ids of kept categories and removes dropped ones',
    () async {
      await notifier().savePlan('plan', [
        allocation('b-food', 'food', 200),
        allocation('b-rent', 'rent', 500),
      ]);

      await notifier().savePlan('plan', [
        allocation('new-id-1', 'food', 300),
        allocation('new-id-2', 'fuel', 100),
      ]);

      final ids = {for (final b in plan().allocations) b.categoryId: b.id};
      expect(ids, {'food': 'b-food', 'fuel': 'new-id-2'});
      expect(plan().totalLimit, 400);
    },
  );

  test('delete can be undone', () async {
    await notifier().savePlan('plan', [allocation('b-food', 'food', 200)]);
    final removed = await notifier().deletePlan('plan');
    expect(container.read(budgetProvider).plans, isEmpty);

    await notifier().restore(removed);
    expect(plan().allocations.single.id, 'b-food');
  });

  test('renewing an ended plan creates a current copy', () async {
    final lastMonth = BudgetDateRange.forPeriod(
      BudgetPeriodType.monthly,
      DateTime(now.year, now.month - 1),
    );
    await notifier().savePlan('old', [
      allocation('b-old', 'food', 200, planId: 'old', range: lastMonth),
    ]);
    final state = container.read(budgetProvider);
    expect(state.endedPlans(now).single.planId, 'old');
    expect(state.isRenewed(plan('old'), now), isFalse);

    final newId = await notifier().renewPlan('old');

    final renewed = plan(newId!);
    expect(renewed.range, thisMonth);
    expect(renewed.status(now), BudgetStatus.active);
    expect(renewed.totalLimit, 200);
    expect(container.read(budgetProvider).isRenewed(plan('old'), now), isTrue);
  });

  test('alerts once at the warning level and once at the limit', () async {
    container.read(budgetAlertsProvider);
    await notifier().savePlan('plan', [allocation('b-food', 'food', 100)]);

    await addExpense('t1', 50);
    expect(fcm.sent, isEmpty);

    await addExpense('t2', 35);
    expect(fcm.sent, ['budget-alert-b-food-80']);

    await addExpense('t3', 20);
    await addExpense('t4', 5);
    expect(fcm.sent, ['budget-alert-b-food-80', 'budget-alert-b-food-100']);
  });

  test(
    'closing stops counting new spending and reopening resumes it',
    () async {
      await notifier().savePlan('plan', [allocation('b-food', 'food', 100)]);
      await addExpense(
        'before',
        40,
        date: DateTime.now().subtract(const Duration(milliseconds: 5)),
      );

      await notifier().closePlan('plan');
      await addExpense(
        'after',
        30,
        date: DateTime.now().add(const Duration(seconds: 1)),
      );

      final closed = plan();
      expect(closed.status(DateTime.now()), BudgetStatus.closed);
      expect(closed.totalSpent, 40);
      final state = container.read(budgetProvider);
      expect(state.currentPlans(DateTime.now()), isEmpty);
      expect(state.endedPlans(DateTime.now()).single.planId, 'plan');

      await notifier().reopenPlan('plan');
      expect(plan().status(DateTime.now()), BudgetStatus.active);
      expect(plan().totalSpent, 70);
    },
  );

  test('marks a plan and category as fully used at 100%', () async {
    await notifier().savePlan('plan', [
      allocation('b-food', 'food', 100),
      allocation('b-rent', 'rent', 300),
    ]);
    await addExpense('t1', 100);

    expect(
      plan().isUsedUp(plan().allocations.firstWhere((b) => b.id == 'b-food')),
      isTrue,
    );
    expect(plan().isFullyUsed, isFalse);

    await addExpense('t2', 300, category: 'rent');
    expect(plan().isFullyUsed, isTrue);
  });

  test('renewing a plan closed early starts the following period', () async {
    await notifier().savePlan('plan', [allocation('b-food', 'food', 100)]);
    await notifier().closePlan('plan');

    final newId = await notifier().renewPlan('plan');

    final renewed = plan(newId!);
    expect(renewed.range.start, thisMonth.endExclusive);
    expect(renewed.status(DateTime.now()), BudgetStatus.upcoming);
    expect(renewed.closedAt, isNull);
    expect(
      container.read(budgetProvider).isRenewed(plan(), DateTime.now()),
      isTrue,
    );
  });
}
