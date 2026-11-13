import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/constants/branding.dart';
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
  });

  final TransactionModel transaction;
  final String categoryName;
  final String categoryColor;
  final int categoryIconCode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = transaction.type == TransactionType.expense;
    final isTransfer = transaction.type == TransactionType.transfer;
    final color = _hexToColor(categoryColor);

    final amountColor =
        isExpense
            ? const Color(0xFFE11D48)
            : isTransfer
            ? const Color(0xFF0284C7)
            : const Color(0xFF059669);

    final tileBg = isDark ? AppBrand.surfaceDark : Colors.white;
    final borderColor = isDark ? AppBrand.borderDark : AppBrand.borderLight;
    final titleColor =
        isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : AppBrand.textSecondaryLight;
    final metaColor =
        isDark ? const Color(0xFF64748B) : AppBrand.textMutedLight;

    return Slidable(
      key: ValueKey(transaction.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            icon: AppIcons.edit,
            label: 'Edit',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(14),
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            icon: AppIcons.delete,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(14),
            ),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: 12),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconData(categoryIconCode, fontFamily: 'MaterialIcons'),
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: titleColor,
                    ),
                  ),
                  if (transaction.notes != null &&
                      transaction.notes!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      transaction.notes!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Amount + time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense || isTransfer ? '-' : '+'}${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('h:mm a').format(transaction.date),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: metaColor,
                  ),
                ),
              ],
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
      return Colors.grey;
    }
  }
}
