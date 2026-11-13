import 'package:expenser/core/utils/formatters/date_labels.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/viewmodels/currency_viewmodel.dart';
import 'package:expenser/viewmodels/exchange_rates_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Hero card showing the conversion, or loading/failure states for rates.
class ConversionResultCard extends StatelessWidget {
  const ConversionResultCard({
    super.key,
    required this.conversion,
    required this.rates,
    required this.onRefresh,
    required this.onRetry,
  });

  final CurrencyState conversion;
  final ExchangeRatesState rates;
  final VoidCallback onRefresh;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: double.infinity,
      child: AppSurfaceCard(
        color: palette.hero,
        borderColor: palette.hero,
        padding: EdgeInsets.all(context.rs(20)),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: switch (rates.status) {
            RatesStatus.loading => const _LoadingBody(),
            RatesStatus.failure => _FailureBody(
              message: rates.errorMessage,
              onRetry: onRetry,
            ),
            RatesStatus.ready => _ResultBody(
              conversion: conversion,
              rates: rates,
              onRefresh: onRefresh,
            ),
          },
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      liveRegion: true,
      label: 'Loading exchange rates',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.rs(16)),
        child: Center(
          child: SizedBox.square(
            dimension: context.rs(28),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: palette.onHero,
            ),
          ),
        ),
      ),
    );
  }
}

class _FailureBody extends StatelessWidget {
  const _FailureBody({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        Icon(
          Icons.cloud_off_rounded,
          color: palette.onHeroWarning,
          size: context.rs(28),
        ),
        SizedBox(height: context.rs(8)),
        Text(
          message ?? 'Could not load exchange rates.',
          textAlign: TextAlign.center,
          style: TextStyle(color: palette.onHero, fontSize: context.rs(14)),
        ),
        SizedBox(height: context.rs(12)),
        TextButton.icon(
          onPressed: onRetry,
          style: TextButton.styleFrom(foregroundColor: palette.onHero),
          icon: Icon(Icons.refresh_rounded, size: context.rs(18)),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.conversion,
    required this.rates,
    required this.onRefresh,
  });

  final CurrencyState conversion;
  final ExchangeRatesState rates;
  final VoidCallback onRefresh;

  static final _amountFormat = NumberFormat.decimalPatternDigits(
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final state = conversion;
    final result = state.resultFrom(rates.rates);
    final rate = state.rateFrom(rates.rates);

    return Column(
      children: [
        Text(
          '${_amountFormat.format(state.amount)} ${state.fromCurrency}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.onHeroMuted,
            fontSize: context.rs(14),
          ),
        ),
        Icon(
          Icons.arrow_downward_rounded,
          color: palette.onHeroMuted,
          size: context.rs(18),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            result == null
                ? '— ${state.toCurrency}'
                : '${_amountFormat.format(result)} ${state.toCurrency}',
            style: TextStyle(
              color: palette.onHero,
              fontSize: context.rs(28),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: context.rs(4)),
        Text(
          rate == null
              ? 'Rate unavailable for this pair'
              : '1 ${state.fromCurrency} = ${_formatRate(rate)} ${state.toCurrency}',
          style: TextStyle(
            color: palette.onHeroMuted,
            fontSize: context.rs(11),
          ),
        ),
        SizedBox(height: context.rs(12)),
        _RatesFooter(state: rates, onRefresh: onRefresh),
      ],
    );
  }

  /// Keeps ~4 significant digits for very small cross rates.
  static String _formatRate(double rate) {
    final digits = rate >= 1 ? 4 : 6;
    return NumberFormat.decimalPatternDigits(
      decimalDigits: digits,
    ).format(rate);
  }
}

class _RatesFooter extends StatelessWidget {
  const _RatesFooter({required this.state, required this.onRefresh});

  final ExchangeRatesState state;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final updatedAt = state.rates?.updatedAt;
    final updatedLabel =
        updatedAt == null ? '' : relativeDateTimeLabel(updatedAt);
    final label =
        state.isStale
            ? 'Offline · rates from $updatedLabel'
            : 'Mid-market rate · updated $updatedLabel';

    return Row(
      children: [
        if (state.isStale) ...[
          Icon(
            Icons.cloud_off_rounded,
            size: context.rs(14),
            color: palette.onHeroWarning,
          ),
          SizedBox(width: context.rs(6)),
        ],
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            style: TextStyle(
              color:
                  state.isStale ? palette.onHeroWarning : palette.onHeroMuted,
              fontSize: context.rs(11),
            ),
          ),
        ),
        state.isRefreshing
            ? Padding(
              padding: EdgeInsets.all(context.rs(12)),
              child: SizedBox.square(
                dimension: context.rs(16),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.onHeroMuted,
                ),
              ),
            )
            : IconButton(
              onPressed: onRefresh,
              tooltip: 'Refresh rates',
              color: palette.onHeroMuted,
              iconSize: context.rs(18),
              icon: const Icon(Icons.refresh_rounded),
            ),
      ],
    );
  }
}
