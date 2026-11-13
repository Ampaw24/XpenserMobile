import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.currency,
    required this.monthlyIncome,
    required this.monthlyExpense,
    this.spendingTrendPercent,
    this.onAnalyticsTap,
    this.footnote,
    this.footnoteIsWarning = false,
  });

  final double totalBalance;
  final String currency;
  final double monthlyIncome;
  final double monthlyExpense;

  /// Month-over-month change in expenses; null when there is no prior month.
  final double? spendingTrendPercent;
  final VoidCallback? onAnalyticsTap;

  /// Context for the total, e.g. currency-conversion details.
  final String? footnote;
  final bool footnoteIsWarning;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  static final _amountFormat = NumberFormat('#,##0.00');
  static const _masked = '••••••';

  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedWhite = Colors.white.withValues(alpha: 0.72);

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.rs(18),
        context.rs(16),
        context.rs(18),
        context.rs(18),
      ),
      decoration: BoxDecoration(
        color: context.palette.hero,
        borderRadius: BorderRadius.circular(context.rs(22)),
        boxShadow: [
          BoxShadow(
            color: AppBrand.spruceDark.withValues(alpha: isDark ? 0.4 : 0.18),
            blurRadius: context.rs(20),
            offset: Offset(0, context.rs(8)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(context, mutedWhite),
          SizedBox(height: context.rs(14)),
          _buildAmountRow(context),
          if (widget.footnote != null) ...[
            SizedBox(height: context.rs(6)),
            Text(
              widget.footnote!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: context.rs(10.5),
                color:
                    widget.footnoteIsWarning
                        ? context.palette.onHeroWarning
                        : mutedWhite,
              ),
            ),
          ],
          SizedBox(height: context.rs(16)),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
          SizedBox(height: context.rs(12)),
          Row(
            children: [
              Expanded(
                child: _MonthStat(
                  icon: AppIcons.arrowDown,
                  label: 'Income',
                  value: _formatMoney(widget.monthlyIncome),
                ),
              ),
              Expanded(
                child: _MonthStat(
                  icon: AppIcons.arrowUp,
                  label: 'Expenses',
                  value: _formatMoney(widget.monthlyExpense),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, Color mutedWhite) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(context.rs(5)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(context.rs(8)),
          ),
          child: HugeIcon(
            icon: AppIcons.wallet,
            color: context.palette.onHeroSuccess,
            size: context.rs(14),
          ),
        ),
        SizedBox(width: context.rs(8)),
        Flexible(
          child: Text(
            'Total Balance',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: context.rs(13),
              fontWeight: FontWeight.w500,
              color: mutedWhite,
            ),
          ),
        ),
        IconButton(
          tooltip: _hidden ? 'Show balance' : 'Hide balance',
          visualDensity: VisualDensity.compact,
          onPressed: () => setState(() => _hidden = !_hidden),
          icon: HugeIcon(
            icon: _hidden ? AppIcons.hide : AppIcons.show,
            color: mutedWhite,
            size: context.rs(17),
          ),
        ),
        const Spacer(),
        if (widget.onAnalyticsTap != null)
          IconButton(
            tooltip: 'Budgets',
            visualDensity: VisualDensity.compact,
            onPressed: widget.onAnalyticsTap,
            icon: HugeIcon(
              icon: AppIcons.chartBars,
              color: AppBrand.mintAccent,
              size: context.rs(20),
            ),
          ),
      ],
    );
  }

  Widget _buildAmountRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: widget.totalBalance),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder:
                  (context, value, _) => _AmountText(
                    currency: widget.currency,
                    formatted: _hidden ? null : _amountFormat.format(value),
                  ),
            ),
          ),
        ),
        if (widget.spendingTrendPercent != null) ...[
          SizedBox(width: context.rs(10)),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: _TrendBadge(percent: widget.spendingTrendPercent!),
            ),
          ),
        ],
      ],
    );
  }

  String _formatMoney(double value) =>
      _hidden
          ? '${widget.currency} $_masked'
          : '${widget.currency} ${_amountFormat.format(value)}';
}

class _AmountText extends StatelessWidget {
  const _AmountText({required this.currency, required this.formatted});

  final String currency;

  /// Null renders the masked balance.
  final String? formatted;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      fontSize: context.rs(34),
    );
    final minorStyle = baseStyle.copyWith(
      fontSize: context.rs(20),
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );

    final value = formatted;
    if (value == null) {
      return Text('$currency ${_BalanceCardState._masked}', style: baseStyle);
    }

    final separator = value.lastIndexOf('.');
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$currency ', style: minorStyle),
          TextSpan(text: value.substring(0, separator), style: baseStyle),
          TextSpan(text: value.substring(separator), style: minorStyle),
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final spendingUp = percent > 0;
    final arrow = spendingUp ? '▲' : '▼';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.rs(8),
            vertical: context.rs(3),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(context.rs(20)),
          ),
          child: Text(
            '$arrow ${percent.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: context.rs(11),
              fontWeight: FontWeight.w600,
              color:
                  spendingUp
                      ? context.palette.onHeroDanger
                      : context.palette.onHeroSuccess,
            ),
          ),
        ),
        SizedBox(height: context.rs(4)),
        Text(
          'spending vs last month',
          style: TextStyle(
            fontSize: context.rs(10),
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

class _MonthStat extends StatelessWidget {
  const _MonthStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HugeIcon(icon: icon, color: AppBrand.mintAccent, size: context.rs(14)),
        SizedBox(width: context.rs(6)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label · this month',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.rs(10.5),
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.rs(13),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
