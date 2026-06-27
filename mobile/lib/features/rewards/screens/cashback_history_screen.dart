/// SRIBEESonline - Cash Back History
///
/// Pushed from the Profile rewards card: balance card → filter chips
/// (All / Earned / Spent) → activity list (earned credited / spent debited).
/// Bottom nav (Profile active) + FAB.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/sribees_design.dart';

enum _CbFilter { all, earned, spent }

class _Activity {
  final bool earned;
  final String title;
  final String order;
  final String date;
  final double amount;
  const _Activity(
      this.earned, this.title, this.order, this.date, this.amount);
}

const _activities = <_Activity>[
  _Activity(true, 'Cash Back Earned', '#SR1234', 'May 24, 2024', 85),
  _Activity(false, 'Cash Back Spent', '#SR0982', 'May 20, 2024', 120),
  _Activity(true, 'Cash Back Earned', '#SR0744', 'May 15, 2024', 125),
];

const _earnedGreen = Color(0xFF2F8A3C);
const _spentRed = Color(0xFFCF3A3A);

class CashBackHistoryScreen extends ConsumerStatefulWidget {
  const CashBackHistoryScreen({super.key});

  @override
  ConsumerState<CashBackHistoryScreen> createState() =>
      _CashBackHistoryScreenState();
}

class _CashBackHistoryScreenState extends ConsumerState<CashBackHistoryScreen> {
  _CbFilter _filter = _CbFilter.all;

  @override
  Widget build(BuildContext context) {
    final list = _activities.where((a) {
      switch (_filter) {
        case _CbFilter.all:
          return true;
        case _CbFilter.earned:
          return a.earned;
        case _CbFilter.spent:
          return !a.earned;
      }
    }).toList();

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          SribeesAppBar(
            title: 'Cash Back History',
            centerTitle: true,
            onBack: () => Navigator.of(context).maybePop(),
            trailing: GestureDetector(
              onTap: () => showToast(context, 'Cash back help'),
              child: const Icon(Icons.help_outline_rounded,
                  color: Colors.white, size: 24),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _balanceCard(),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      _chip('All', _CbFilter.all),
                      const SizedBox(width: 10),
                      _chip('Earned', _CbFilter.earned),
                      const SizedBox(width: 10),
                      _chip('Spent', _CbFilter.spent),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text('Recent Activities',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: kInk)),
                  const SizedBox(height: 16),
                  ...list.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ActivityCard(activity: a),
                      )),
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: const [
                        Icon(Icons.history_toggle_off_rounded,
                            size: 34, color: Color(0xFFC2BECE)),
                        SizedBox(height: 10),
                        Text('End of History',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: kPlaceholder)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          SribeesBottomNav(selected: 3, onTap: (i) => popToTab(context, ref, i)),
      floatingActionButton: SribeesSparkleFab(
          onTap: () => showToast(context, '✨ AI shopping assistant')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: swatch(kMagenta, kMagentaAppbarStart),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: kMagenta.withValues(alpha: 0.4),
            blurRadius: 38,
            spreadRadius: -22,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CURRENT CASH BACK BALANCE',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          const Text('Rs. 450.00',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5)),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => showToast(context, 'Redeem cash back'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Text('Redeem Now',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, _CbFilter filter) {
    final active = _filter == filter;
    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 11),
        decoration: BoxDecoration(
          color: active ? kMagenta : kBorder,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? Colors.white : const Color(0xFF6A6A74),
                fontSize: 15,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final _Activity activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final color = activity.earned ? _earnedGreen : _spentRed;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: cardShadow(opacity: 0.18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: activity.earned
                  ? const Color(0xFFD8F0CC)
                  : const Color(0xFFFAD9D9),
              shape: BoxShape.circle,
            ),
            child: Icon(activity.earned ? Icons.add : Icons.remove,
                color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kInk)),
                const SizedBox(height: 3),
                Text('Order ${activity.order} · ${activity.date}',
                    style: const TextStyle(fontSize: 13, color: kMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${activity.earned ? '+' : '–'}Rs. ${money(activity.amount)}',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: color),
              ),
              const SizedBox(height: 5),
              Text(activity.earned ? 'CREDITED' : 'DEBITED',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: kMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
