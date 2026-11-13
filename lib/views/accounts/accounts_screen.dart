import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_empty_state.dart';
import 'package:expenser/core/utils/widgets/app_page_header.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/account_type.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountProvider);

    return Scaffold(
      body: BrandWatermarkBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(title: 'Accounts'),
              Expanded(
                child:
                    state.accounts.isEmpty
                        ? const AppEmptyState(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'No accounts yet',
                          message: 'Tap + to add an account',
                        )
                        : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            context.contentGutter,
                            0,
                            context.contentGutter,
                            context.rs(96),
                          ),
                          itemCount: state.accounts.length,
                          separatorBuilder:
                              (_, __) => SizedBox(height: context.rs(12)),
                          itemBuilder: (context, i) {
                            final account = state.accounts[i];
                            return _AccountTile(
                              account: account,
                              balance: state.balances[account.id] ?? 0,
                              onTap:
                                  () => context.push(
                                    '/accounts/${account.id}/edit',
                                  ),
                              onDelete:
                                  () => ref
                                      .read(accountProvider.notifier)
                                      .deleteAccount(account.id),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_accounts',
        tooltip: 'Add account',
        onPressed: () => context.push('/accounts/add'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.balance,
    required this.onTap,
    required this.onDelete,
  });

  final AccountModel account;
  final double balance;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = _hexToColor(account.colorHex, palette.accent);
    final typeLabel = account.type.label;

    return Dismissible(
      key: ValueKey(account.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: context.rs(20)),
        decoration: BoxDecoration(
          color: palette.danger,
          borderRadius: BorderRadius.circular(context.rs(18)),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: AppSurfaceCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.rs(11)),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(context.rs(14)),
              ),
              child: Icon(
                IconData(account.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: color,
                size: context.rs(22),
              ),
            ),
            SizedBox(width: context.rs(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.rs(15),
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  SizedBox(height: context.rs(2)),
                  Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: context.rs(12),
                      color: palette.textSecondary,
                    ),
                  ),
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
                      '${account.currencyCode} ${balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: context.rs(15),
                        fontWeight: FontWeight.w700,
                        color:
                            balance < 0 ? palette.danger : palette.textPrimary,
                      ),
                    ),
                    SizedBox(height: context.rs(2)),
                    Text(
                      'Balance',
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

  static Color _hexToColor(String hex, Color fallback) {
    try {
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}
