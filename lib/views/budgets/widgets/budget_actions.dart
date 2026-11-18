import 'package:expenser/core/utils/widgets/app_feedback_dialog.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> confirmBudgetDelete(BuildContext context) {
  return AppDialogs.confirm(
    context,
    title: 'Delete this budget?',
    message:
        'All its category limits will be removed. '
        'Your transactions are not affected.',
    confirmText: 'Delete',
    isDestructive: true,
  );
}

/// Deletes the plan and offers Undo. Grab [messenger] before any navigation
/// so the snackbar survives the caller's page being popped.
Future<void> deleteBudgetWithUndo({
  required WidgetRef ref,
  required ScaffoldMessengerState messenger,
  required String planId,
}) async {
  final notifier = ref.read(budgetProvider.notifier);
  final removed = await notifier.deletePlan(planId);
  if (removed.isEmpty) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text('Budget deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => notifier.restore(removed),
        ),
      ),
    );
}

Future<bool> confirmBudgetClose(BuildContext context) {
  return AppDialogs.confirm(
    context,
    title: 'Close this budget?',
    message:
        'It moves to Ended and new spending will no longer count '
        'against it. You can reopen it later.',
    confirmText: 'Close budget',
    icon: Icons.archive_outlined,
  );
}

/// Closes the plan after confirmation and offers Undo.
Future<void> closeBudgetWithUndo(
  BuildContext context,
  WidgetRef ref,
  String planId,
) async {
  if (!await confirmBudgetClose(context) || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final notifier = ref.read(budgetProvider.notifier);
  await notifier.closePlan(planId);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text('Budget closed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => notifier.reopenPlan(planId),
        ),
      ),
    );
}
