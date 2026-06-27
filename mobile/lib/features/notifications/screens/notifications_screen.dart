/// SRIBEESonline - Notifications
///
/// Pushed screen: magenta app bar → hero banner → "Recent" feed (one featured
/// card highlighted) → "For You" grid. Bottom nav (Profile active) + FAB.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/sribees_design.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          SribeesAppBar(
            title: 'Notifications',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heroBanner(),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: kInk)),
                      GestureDetector(
                        onTap: () => showToast(context, 'All marked as read'),
                        child: const Text('Mark all as read',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: kMagentaAppbarStart)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _NotifCard(
                    iconBg: const Color(0xFFD8F0CC),
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: const Color(0xFF2F8A3C),
                    title: 'Order Delivered',
                    time: '2 mins ago',
                    body: 'Your order #SR1234 has been delivered. Enjoy your '
                        'fresh produce!',
                  ),
                  const SizedBox(height: 14),
                  _NotifCard(
                    iconBg: kMagentaTint,
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: kMagenta,
                    title: 'Cash Back Earned!',
                    time: '1 hour ago',
                    body: 'You just earned Rs. 85.00 cash back from your last '
                        'order.',
                  ),
                  const SizedBox(height: 14),
                  _HighlightCard(),
                  const SizedBox(height: 14),
                  _NotifCard(
                    iconBg: kMagentaTint,
                    icon: Icons.local_offer_outlined,
                    iconColor: kMagenta,
                    title: 'Flash Sale Alert',
                    time: '5 hours ago',
                    body: 'Get 20% off on all organic fruits today only!',
                  ),
                  const SizedBox(height: 14),
                  _NotifCard(
                    iconBg: const Color(0xFFE3E2E4),
                    icon: Icons.credit_card_outlined,
                    iconColor: const Color(0xFF6A6A74),
                    title: 'Wallet Refill',
                    time: '1 day ago',
                    body: 'Rs. 500.00 added to your SRIBEES Wallet.',
                  ),

                  const SizedBox(height: 30),
                  const Text('For You',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: kInk)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ForYouTile(
                          iconBg: kMagentaTint,
                          icon: Icons.settings_outlined,
                          iconColor: kMagenta,
                          label: 'Notifications',
                          onTap: () =>
                              showToast(context, 'Notification settings'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ForYouTile(
                          iconBg: const Color(0xFFE3E2E4),
                          icon: Icons.help_outline_rounded,
                          iconColor: const Color(0xFF6A6A74),
                          label: 'Help Center',
                          onTap: () => showToast(context, 'Help Center'),
                        ),
                      ),
                    ],
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

  Widget _heroBanner() {
    return Container(
      height: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B1419), Color(0xFF5A3A2C), Color(0xFF8A2350)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF14080C).withValues(alpha: 0.55),
                  const Color(0xFF14080C).withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.7],
              ),
            ),
            child: const SizedBox.expand(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      color: kMagenta,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Text('LATEST UPDATES',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8)),
                ),
                const SizedBox(height: 12),
                const Text('Stay Fresh,\nStay Informed.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.05)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;
  final String body;
  const _NotifCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: kInk)),
                    ),
                    Text(time,
                        style: const TextStyle(fontSize: 12, color: kMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(
                        fontSize: 14, height: 1.45, color: kInk2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kMagentaAppbarStart, width: 2),
        boxShadow: [
          BoxShadow(
            color: kMagentaAppbarStart.withValues(alpha: 0.25),
            blurRadius: 30,
            spreadRadius: -22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekend Harvest',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: kInk)),
                SizedBox(height: 5),
                Text('Up to 40% off on all seasonal berries this Saturday.',
                    style: TextStyle(fontSize: 14, height: 1.45, color: kInk2)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.eco_outlined, color: kMagenta, size: 30),
        ],
      ),
    );
  }
}

class _ForYouTile extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  const _ForYouTile({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: kFill,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: kInk)),
          ],
        ),
      ),
    );
  }
}
