/// SRIBEESonline - Profile tab
///
/// Account / rewards / settings, matching the prototype: avatar + identity,
/// GOLD MEMBER + points, rewards card (→ Cash Back History), menu list
/// (Payment Methods, Notifications, …), Logout, version footer.
/// Rendered inside the main shell's IndexedStack (no own Scaffold/header).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/sribees_design.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../payment/screens/payment_methods_screen.dart';
import '../../rewards/screens/cashback_history_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        children: [
          // Avatar + identity
          _avatar(context),
          const SizedBox(height: 16),
          const Text('Kasun Perera',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                  letterSpacing: -0.5)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: 'SR12345'));
              showToast(context, 'ID copied to clipboard');
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('ID: SR12345',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6A6A74))),
                SizedBox(width: 7),
                Icon(Icons.copy_rounded, size: 15, color: Color(0xFF9B97A1)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: kMagenta, borderRadius: BorderRadius.circular(20)),
                child: const Text('GOLD MEMBER',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4)),
              ),
              const SizedBox(width: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.stars_rounded, color: kMagenta, size: 20),
                  SizedBox(width: 6),
                  Text('2,450 Points',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kInk)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Rewards card
          _rewardsCard(context),
          const SizedBox(height: 22),

          // Menu
          _MenuRow(
            icon: Icons.person_outline_rounded,
            label: 'My Account',
            sub: 'Personal info, addresses',
            onTap: () => showToast(context, 'My Account'),
          ),
          const SizedBox(height: 14),
          _MenuRow(
            icon: Icons.credit_card_rounded,
            label: 'Payment Methods',
            sub: 'Visa, Mastercard, Koko',
            onTap: () => _push(context, const PaymentMethodsScreen()),
          ),
          const SizedBox(height: 14),
          _MenuRow(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            sub: 'Offers, order updates',
            showDot: true,
            onTap: () => _push(context, const NotificationsScreen()),
          ),
          const SizedBox(height: 14),
          _MenuRow(
            icon: Icons.settings_outlined,
            label: 'Settings',
            sub: 'Security, privacy, language',
            onTap: () => showToast(context, 'Settings'),
          ),
          const SizedBox(height: 14),
          _MenuRow(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            sub: 'FAQ, contact us',
            onTap: () => showToast(context, 'Help & Support'),
          ),
          const SizedBox(height: 14),
          _MenuRow(
            icon: Icons.group_outlined,
            label: 'Invite Friends',
            sub: 'Get Rs. 200 for each friend',
            onTap: () => showToast(context, 'Invite Friends'),
          ),
          const SizedBox(height: 20),

          // Logout
          GestureDetector(
            onTap: () => showToast(context, 'Logged out'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EE),
                  borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.logout_rounded,
                        color: kMagenta, size: 22),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Logout',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: kMagenta)),
                        SizedBox(height: 2),
                        Text('SIGN OUT OF YOUR ACCOUNT',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                color: Color(0xFFCF7D9C))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFE3A9C1), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          const Text('SRIBEES V4.2.0 · SRILANKA',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: Color(0xFFC2BECE))),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _avatar(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: kMagenta, width: 3),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    swatch(const Color(0xFFC98B6A), const Color(0xFF9A5D44)),
              ),
              alignment: Alignment.center,
              child: const Text('KP',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: GestureDetector(
              onTap: () => showToast(context, 'Edit profile'),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kMagentaDeep,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBg, width: 3),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardsCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _push(context, const CashBackHistoryScreen()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: swatch(kMagenta, kMagentaDeep),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: kMagenta.withValues(alpha: 0.5),
              blurRadius: 32,
              spreadRadius: -18,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SRIBEES REWARDS',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8)),
                  SizedBox(height: 4),
                  Text('Rs. 450.00',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1)),
                  SizedBox(height: 2),
                  Text('Cash Back Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white, size: 26),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool showDot;
  final VoidCallback onTap;
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: cardShadow(opacity: 0.16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: kMagentaTint,
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: kMagenta, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: kInk)),
                      if (showDot) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: kMagenta, shape: BoxShape.circle),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: const TextStyle(fontSize: 13, color: kMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFC2BECE), size: 20),
          ],
        ),
      ),
    );
  }
}
