import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> confirmBudgetDelete(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('Delete this budget?'),
          content: const Text(
            'All its category limits will be removed. '
            'Your transactions are not affected.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
  );
  return confirmed ?? false;
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

Future<bool> confirmBudgetClose(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('Close this budget?'),
          content: const Text(
            'It moves to Ended and new spending will no longer count '
            'against it. You can reopen it later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Close budget'),
            ),
          ],
        ),
  );
  return confirmed ?? false;
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
