/// SRIBEESonline - Finalize Order (Checkout)
///
/// Pushed from Cart. Delivery address → payment method (SRIBEES Wallet toggle +
/// select gateway) → order summary (from the real cart) → terms → Place Order
/// (gated by the terms checkbox). Bottom nav (Orders active) + FAB.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/sribees_design.dart';
import '../../../core/providers/cart_provider.dart';
import '../../cart/models/cart_model.dart';

const double _deliveryFee = 350;
const double _walletBalance = 500;
const double _cashBackRate = 0.10;

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _walletOn = true;
  bool _agree = false;

  void _placeOrder() {
    if (!_agree) {
      showToast(context, 'Please agree to the terms');
      return;
    }
    ref.read(cartProvider.notifier).clearCart();
    ref.read(mainTabProvider.notifier).state = 0;
    Navigator.of(context).popUntil((r) => r.isFirst);
    showToast(context, '✓ Order placed successfully!');
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final items = cart.items;
    final subtotal = items.fold<double>(0, (s, i) => s + i.total);
    final delivery = items.isEmpty ? 0.0 : _deliveryFee;
    final gross = subtotal + delivery;
    final walletDeduction =
        _walletOn ? (gross < _walletBalance ? gross : _walletBalance) : 0.0;
    final total = gross - walletDeduction;
    final cashBack = subtotal * _cashBackRate;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backButton(),
              const SizedBox(height: 16),
              const Text('Finalize Order',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                      letterSpacing: -0.3)),
              const SizedBox(height: 6),
              const Text(
                  'Review your details before we prepare your delivery.',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF5A5A64), height: 1.4)),
              const SizedBox(height: 24),

              _deliveryCard(),
              const SizedBox(height: 16),
              _paymentCard(walletDeduction, total),
              const SizedBox(height: 16),
              _summaryCard(items, subtotal, delivery, walletDeduction, total,
                  cashBack),
              const SizedBox(height: 16),

              // Terms
              GestureDetector(
                onTap: () => setState(() => _agree = !_agree),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: kFill, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CheckBox(selected: _agree),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                fontSize: 13, height: 1.5, color: kInk2),
                            children: [
                              TextSpan(text: "I agree to the SRIBEES' "),
                              TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                      color: kMagentaAppbarStart,
                                      fontWeight: FontWeight.w700)),
                              TextSpan(text: ' and '),
                              TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                      color: kMagentaAppbarStart,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Place order
              GestureDetector(
                onTap: _placeOrder,
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: _agree
                        ? swatch(kMagenta, kMagentaDeep)
                        : null,
                    color: _agree ? null : const Color(0xFFF1C7D8),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Place Order',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      SizedBox(width: 9),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          SribeesBottomNav(selected: 2, onTap: (i) => popToTab(context, ref, i)),
      floatingActionButton: SribeesSparkleFab(
          onTap: () => showToast(context, '✨ AI shopping assistant')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: kMagenta,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kMagenta.withValues(alpha: 0.5),
              blurRadius: 14,
              spreadRadius: -6,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: cardShadow(opacity: 0.18),
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: kMagenta, size: 18),
        const SizedBox(width: 9),
        Text(title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: kInk)),
      ],
    );
  }

  Widget _deliveryCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.location_on_rounded, 'Delivery Address'),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => showToast(context, 'Change delivery address'),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                  color: kFill, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: const [
                  Icon(Icons.home_outlined, color: Color(0xFF8C8C97), size: 17),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text('42/A, Flower Road, Colombo 07...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kInk)),
                  ),
                  Icon(Icons.chevron_right_rounded, color: kMuted, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Contact Phone Number',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5A5A64))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Row(
              children: const [
                Icon(Icons.phone_outlined, color: kMuted, size: 16),
                SizedBox(width: 10),
                Text('07X XXX XXXX',
                    style: TextStyle(
                        fontSize: 13,
                        color: kPlaceholder,
                        letterSpacing: 0.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(double walletDeduction, double total) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.credit_card_rounded, 'Payment Method'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xFFFCE7F0),
                borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        color: kMagenta, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SRIBEES Wallet',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: kInk)),
                          SizedBox(height: 1),
                          Text('Balance: Rs. 500.00',
                              style: TextStyle(fontSize: 11, color: kMuted)),
                        ],
                      ),
                    ),
                    _Toggle(
                      on: _walletOn,
                      onTap: () => setState(() => _walletOn = !_walletOn),
                    ),
                  ],
                ),
                if (_walletOn) ...[
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Enter amount to use',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kInk2)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text('Rs.  ${money(walletDeduction)}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kInk)),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Rs. ${money(walletDeduction)} will be deducted from your '
                    'total. Please pay the remaining Rs. ${money(total)} using '
                    'another method.',
                    style: TextStyle(
                        fontSize: 11,
                        color: kMagentaAppbarStart.withValues(alpha: 0.85),
                        height: 1.5),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => showToast(context, 'Select payment method'),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                  color: kFill, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: const [
                  Icon(Icons.account_balance_outlined,
                      color: Color(0xFF8C8C97), size: 18),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text('ගෙවීම් ක්‍රමය තෝරන්න (Select Payment Method)',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: kInk,
                            height: 1.35)),
                  ),
                  Icon(Icons.chevron_right_rounded, color: kMuted, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    List<CartItem> items,
    double subtotal,
    double delivery,
    double walletDeduction,
    double total,
    double cashBack,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.receipt_long_outlined, 'Order Summary'),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('No items in your order',
                style: TextStyle(fontSize: 13, color: kMuted))
          else
            ...items.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('${i.name} (x${i.quantity})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, color: kInk2)),
                      ),
                      Text('Rs. ${money(i.total)}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kInk)),
                    ],
                  ),
                )),
          const _DashedLine(),
          const SizedBox(height: 14),
          _row('Subtotal', 'Rs. ${money(subtotal)}'),
          const SizedBox(height: 10),
          _row('Delivery Fee', 'Rs. ${money(delivery)}'),
          if (walletDeduction > 0) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Wallet Deduction',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kMagentaAppbarStart)),
                Text('- Rs. ${money(walletDeduction)}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kMagentaAppbarStart)),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: kBorder),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL AMOUNT',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: kMuted.withValues(alpha: 0.8))),
                  const SizedBox(height: 3),
                  Text('Rs. ${money(total)}',
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: kMagenta,
                          letterSpacing: -0.5)),
                ],
              ),
              Icon(Icons.verified_outlined,
                  size: 26, color: kMagenta.withValues(alpha: 0.3)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
                color: kSuccessBg, borderRadius: BorderRadius.circular(12)),
            child: Text(
              'You will earn Rs. ${money(cashBack)} Cash Back on this order',
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: kSuccess,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A5A64))),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: kInk)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bits
// ---------------------------------------------------------------------------

class _Toggle extends StatelessWidget {
  final bool on;
  final VoidCallback onTap;
  const _Toggle({required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: on ? kMagentaAppbarStart : const Color(0xFFCFCDD6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  final bool selected;
  const _CheckBox({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? kMagenta : Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
            color: selected ? kMagenta : const Color(0xFFCFCDD6), width: 2),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: LayoutBuilder(
        builder: (context, c) {
          const dashW = 5.0, gap = 4.0;
          final count = (c.maxWidth / (dashW + gap)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(
                  width: dashW, height: 1.5, color: const Color(0xFFD4D1D9)),
            ),
          );
        },
      ),
    );
  }
}
