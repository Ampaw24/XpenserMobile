import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final state = ref.watch(accountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.06, sh * 0.024, sw * 0.06, sh * 0.020),
              child: Text(
                'Accounts',
                style: GoogleFonts.montserrat(
                  fontSize: sw * 0.058,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            if (state.accounts.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: sw * 0.155,
                        color: Colors.white.withValues(alpha: 0.20)),
                    SizedBox(height: sh * 0.016),
                    Text(
                      'No accounts yet',
                      style: GoogleFonts.inter(
                        fontSize: sw * 0.040,
                        color: Colors.white.withValues(alpha: 0.40),
                      ),
                    ),
                    SizedBox(height: sh * 0.008),
                    Text(
                      'Tap + to add an account',
                      style: GoogleFonts.inter(
                        fontSize: sw * 0.032,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(sw * 0.06, 0, sw * 0.06, sh * 0.12),
                  itemCount: state.accounts.length,
                  separatorBuilder: (_, __) => SizedBox(height: sh * 0.014),
                  itemBuilder: (context, i) {
                    final a = state.accounts[i];
                    final balance = state.balances[a.id] ?? 0;
                    final color = _hexToColor(a.colorHex);
                    return Dismissible(
                      key: ValueKey(a.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: sw * 0.050),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(sw * 0.050),
                        ),
                        child: const Icon(Icons.delete_rounded, color: Colors.white),
                      ),
                      onDismissed: (_) =>
                          ref.read(accountProvider.notifier).deleteAccount(a.id),
                      child: GestureDetector(
                        onTap: () => context.push('/accounts/${a.id}/edit'),
                        child: Container(
                          padding: EdgeInsets.all(sw * 0.050),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color, color.withValues(alpha: 0.70)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(sw * 0.050),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.30),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(sw * 0.026),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(sw * 0.028),
                                ),
                                child: Icon(
                                  IconData(a.iconCodePoint, fontFamily: 'MaterialIcons'),
                                  color: Colors.white,
                                  size: sw * 0.056,
                                ),
                              ),
                              SizedBox(width: sw * 0.040),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.name,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: sw * 0.040,
                                      ),
                                    ),
                                    SizedBox(height: sh * 0.003),
                                    Text(
                                      a.type.name[0].toUpperCase() + a.type.name.substring(1),
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withValues(alpha: 0.70),
                                        fontSize: sw * 0.030,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${a.currencyCode} ${balance.toStringAsFixed(2)}',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: sw * 0.045,
                                    ),
                                  ),
                                  SizedBox(height: sh * 0.003),
                                  Text(
                                    'Balance',
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withValues(alpha: 0.70),
                                      fontSize: sw * 0.028,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_accounts',
        backgroundColor: AppColors.PRIMARY,
        onPressed: () => context.push('/accounts/add'),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return AppColors.PRIMARY;
    }
  }
}
