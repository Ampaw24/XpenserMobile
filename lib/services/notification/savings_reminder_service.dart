import 'package:expenser/models/recurring_frequency.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/models/savings_plan.dart';
import 'package:expenser/models/savings_reminder_schedule.dart';
import 'package:expenser/services/notification/fcm_service.dart';
import 'package:expenser/services/notification/notification_channel.dart';
import 'package:expenser/viewmodels/savings_goal_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final savingsReminderServiceProvider = Provider<SavingsReminderService>(
  (ref) => SavingsReminderService(ref.read(fcmServiceProvider)),
);

/// Watch from a widget that lives for the signed-in session to keep the
/// OS-scheduled reminders in step with goals and the notification setting.
final savingsRemindersProvider = Provider<void>((ref) {
  final goals = ref.watch(savingsGoalProvider);
  final enabled = ref.watch(
    settingsProvider.select((s) => s.notificationsEnabled),
  );
  final currency = ref.watch(
    settingsProvider.select((s) => s.preferredCurrency),
  );
  ref
      .read(savingsReminderServiceProvider)
      .sync(goals, enabled: enabled, currency: currency);
});

/// Stable notification id for a goal's reminder (FNV-1a, 31-bit).
int savingsReminderId(String goalId) {
  var hash = 0x811c9dc5;
  for (final unit in goalId.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}

/// Schedules repeating "time to save" reminders with the OS so they fire
/// while the app is closed. Reminders are identified by their payload.
class SavingsReminderService {
  SavingsReminderService(this._fcm, {FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FcmService _fcm;
  final FlutterLocalNotificationsPlugin _plugin;

  static const _route = '/savings';

  Future<void> _queue = Future.value();
  bool _timeZoneReady = false;

  Future<void> sync(
    List<SavingsGoalModel> goals, {
    required bool enabled,
    required String currency,
  }) => _enqueue(() => _sync(goals, enabled: enabled, currency: currency));

  /// Call on sign-out so the next user never gets this user's reminders.
  Future<void> cancelAll() => _enqueue(() => _cancelWhere((_) => true));

  /// Runs tasks one at a time so overlapping syncs can't interleave.
  Future<void> _enqueue(Future<void> Function() task) {
    return _queue = _queue
        .then((_) => task())
        .catchError((Object e) => debugPrint('Savings reminders: $e'));
  }

  Future<void> _sync(
    List<SavingsGoalModel> goals, {
    required bool enabled,
    required String currency,
  }) async {
    final due =
        enabled
            ? goals.where((g) => g.hasReminder && !g.isCompleted).toList()
            : const <SavingsGoalModel>[];
    final keep = {for (final goal in due) savingsReminderId(goal.id)};
    await _cancelWhere((id) => !keep.contains(id));
    if (due.isEmpty) return;

    await _fcm.ensureLocalNotificationsReady();
    await _ensureTimeZone();
    final now = DateTime.now();
    for (final goal in due) {
      await _schedule(goal, currency, now);
    }
  }

  Future<void> _cancelWhere(bool Function(int id) shouldCancel) async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (request.payload == _route && shouldCancel(request.id)) {
        await _plugin.cancel(request.id);
      }
    }
  }

  Future<void> _schedule(
    SavingsGoalModel goal,
    String currency,
    DateTime now,
  ) async {
    final frequency = goal.savingsFrequency!;
    final next = nextReminderFor(goal, now);
    // Rescheduled after every change, so the amount due stays current.
    final amount = goal.currentPlan(now)?.perPayment ?? goal.contributionAmount;
    await _plugin.zonedSchedule(
      savingsReminderId(goal.id),
      'Time to save for ${goal.name}',
      amount != null && amount > 0
          ? 'Add $currency ${amount.toStringAsFixed(2)} to stay on track.'
          : 'Add to your savings goal to stay on track.',
      tz.TZDateTime(
        tz.local,
        next.year,
        next.month,
        next.day,
        next.hour,
        next.minute,
      ),
      appNotificationDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Inexact delivery needs no exact-alarm permission; a few minutes'
      // drift is fine for a savings nudge.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: switch (frequency) {
        RecurringFrequency.daily => DateTimeComponents.time,
        RecurringFrequency.weekly => DateTimeComponents.dayOfWeekAndTime,
        RecurringFrequency.monthly => DateTimeComponents.dayOfMonthAndTime,
      },
      payload: _route,
    );
  }

  Future<void> _ensureTimeZone() async {
    if (_timeZoneReady) return;
    tz_data.initializeTimeZones();
    final local = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(local.identifier));
    _timeZoneReady = true;
  }
}
