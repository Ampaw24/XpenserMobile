import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final sh = MediaQuery.of(context).size.height;
    final isExpense = transaction.type == TransactionType.expense;
    final isTransfer = transaction.type == TransactionType.transfer;
    final color = _hexToColor(categoryColor);

    final amountColor = isExpense
        ? const Color(0xFFFF5252)
        : isTransfer
            ? const Color(0xFFFFAB40)
            : const Color(0xFF00E676);

    return Slidable(
      key: ValueKey(transaction.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: const Color(0xFF448AFF),
            foregroundColor: Colors.white,
            icon: AppIcons.edit,
            label: 'Edit',
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: const Color(0xFFFF5252),
            foregroundColor: Colors.white,
            icon: AppIcons.delete,
            label: 'Delete',
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(16)),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: sh * 0.010),
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.042,
          vertical: sh * 0.014,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(sw * 0.040),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: sw * 0.112,
              height: sw * 0.112,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(sw * 0.030),
              ),
              child: Icon(
                IconData(categoryIconCode, fontFamily: 'MaterialIcons'),
                color: color,
                size: sw * 0.052,
              ),
            ),
            SizedBox(width: sw * 0.034),

            // Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: sw * 0.038,
                      color: Colors.white,
                    ),
                  ),
                  if (transaction.notes != null &&
                      transaction.notes!.isNotEmpty) ...[
                    SizedBox(height: sh * 0.002),
                    Text(
                      transaction.notes!,
                      style: GoogleFonts.inter(
                        fontSize: sw * 0.030,
                        color: Colors.white.withValues(alpha: 0.45),
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
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: sw * 0.038,
                    color: amountColor,
                  ),
                ),
                SizedBox(height: sh * 0.003),
                Text(
                  DateFormat('h:mm a').format(transaction.date),
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.028,
                    color: Colors.white.withValues(alpha: 0.35),
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
