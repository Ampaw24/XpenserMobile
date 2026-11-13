import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/formatters/date_labels.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIconCode,
    required this.onEdit,
    required this.onDelete,
    this.embedded = false,
  });

  final TransactionModel transaction;
  final String categoryName;
  final String categoryColor;
  final int categoryIconCode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Renders without its own card chrome and shows the date instead of time,
  /// for use inside a grouped list container.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isExpense = transaction.type == TransactionType.expense;
    final isTransfer = transaction.type == TransactionType.transfer;
    final color = _hexToColor(categoryColor);
    final amountColor =
        isExpense
            ? palette.danger
            : isTransfer
            ? palette.info
            : palette.success;
    final actionRadius = Radius.circular(context.rs(14));

    return Slidable(
      key: ValueKey(transaction.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: palette.accent,
            foregroundColor: palette.onAccent,
            icon: AppIcons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.horizontal(left: actionRadius),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: palette.danger,
            foregroundColor: Colors.white,
            icon: AppIcons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.horizontal(right: actionRadius),
          ),
        ],
      ),
      child: Container(
        margin:
            embedded ? EdgeInsets.zero : EdgeInsets.only(bottom: context.rs(8)),
        padding: EdgeInsets.symmetric(
          horizontal: context.rs(16),
          vertical: context.rs(12),
        ),
        decoration:
            embedded
                ? null
                : BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(context.rs(16)),
                  border: Border.all(color: palette.border),
                ),
        child: Row(
          children: [
            Container(
              width: context.rs(42),
              height: context.rs(42),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.rs(12)),
              ),
              child: Icon(
                IconData(categoryIconCode, fontFamily: 'MaterialIcons'),
                color: color,
                size: context.rs(20),
              ),
            ),
            SizedBox(width: context.rs(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: context.rs(14),
                      color: palette.textPrimary,
                    ),
                  ),
                  if (transaction.notes?.isNotEmpty ?? false) ...[
                    SizedBox(height: context.rs(2)),
                    Text(
                      transaction.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.rs(12),
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: context.rs(8)),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense || isTransfer ? '-' : '+'}${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: context.rs(15),
                        color: amountColor,
                      ),
                    ),
                    SizedBox(height: context.rs(2)),
                    Text(
                      embedded
                          ? relativeDayLabel(transaction.date)
                          : DateFormat('h:mm a').format(transaction.date),
                      style: TextStyle(
                        fontSize: context.rs(11),
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return const Color(0xFF78909C);
    }
  }
}
