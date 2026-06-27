/// SRIBEESonline - Orders tab
///
/// Order tracking, matching the "SRIBEES Online" prototype:
/// cart-summary card → "Your Orders" → segmented chips (Active / Past / Return)
///   • Active: live order card (ON THE WAY) + past-orders list
///   • Past:   past-orders list
///   • Return: empty state
/// Rendered inside the main shell's IndexedStack (no own Scaffold/header).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/sribees_design.dart';
import '../../cart/screens/cart_screen.dart';

enum _OrdersTab { active, past, returns }

// ---------------------------------------------------------------------------
// Data (gradient placeholders, mirrors the prototype)
// ---------------------------------------------------------------------------

class _PastOrder {
  final String id;
  final int items;
  final String date;
  final double total;
  final double earned;
  final String more;
  final List<LinearGradient> thumbs;
  const _PastOrder(this.id, this.items, this.date, this.total, this.earned,
      this.more, this.thumbs);
}

final _activeThumbs = <LinearGradient>[
  swatch(const Color(0xFFC97B6E), const Color(0xFFA8463A)),
  swatch(const Color(0xFF7FA67A), const Color(0xFF4D7048)),
  swatch(const Color(0xFF3A3A3A), const Color(0xFF1C1C1C)),
];

final _pastOrders = <_PastOrder>[
  _PastOrder('#SR0982', 5, 'May 20, 2024', 720, 72, '+3', [
    swatch(const Color(0xFF7FA67A), const Color(0xFF4D7048)),
    swatch(const Color(0xFFC9853A), const Color(0xFF9A5E1F)),
  ]),
  _PastOrder('#SR0744', 12, 'May 15, 2024', 1250, 125, '+10', [
    swatch(const Color(0xFF3A3A3A), const Color(0xFF1C1C1C)),
    swatch(const Color(0xFFC5414C), const Color(0xFF8E2630)),
  ]),
];

// ---------------------------------------------------------------------------
// Orders tab
// ---------------------------------------------------------------------------

class OrdersTab extends ConsumerStatefulWidget {
  const OrdersTab({super.key});

  @override
  ConsumerState<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<OrdersTab> {
  _OrdersTab _tab = _OrdersTab.active;

  void _openCart() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CartSummaryCard(onViewCart: _openCart),
          const SizedBox(height: 24),
          const Text(
            'Your Orders',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: kMagenta,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tracking your culinary journey',
            style: TextStyle(fontSize: 14, color: kMuted),
          ),
          const SizedBox(height: 18),

          // Segmented chips
          Row(
            children: [
              _chip('Active Orders', _OrdersTab.active),
              const SizedBox(width: 10),
              _chip('Past Orders', _OrdersTab.past),
              const SizedBox(width: 10),
              _chip('Return Orders', _OrdersTab.returns),
            ],
          ),
          const SizedBox(height: 22),

          if (_tab == _OrdersTab.returns)
            _returnsEmpty()
          else ...[
            if (_tab == _OrdersTab.active) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Orders',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: kInk),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: kMagentaTint,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text(
                      '1 ITEM',
                      style: TextStyle(
                          color: kMagenta,
                          fontSize: 11,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _ActiveOrderCard(),
              const SizedBox(height: 28),
              const Text(
                'Past Orders',
                style: TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w800, color: kInk),
              ),
              const SizedBox(height: 14),
            ],
            ..._pastOrders.map((o) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _PastOrderCard(
                    order: o,
                    onDetails: () => showToast(context, 'Order ${o.id} details'),
                    onReorder: () => showToast(context, 'Reordering ${o.id}'),
                  ),
                )),
            _endOfHistory(),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, _OrdersTab tab) {
    final active = _tab == tab;
    return GestureDetector(
      onTap: () => setState(() => _tab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? kMagenta : kBorder,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF6A6A74),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _returnsEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 54),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.replay_rounded, size: 40, color: Color(0xFFC9C5D0)),
            SizedBox(height: 12),
            Text('No return orders',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB3AFBA))),
          ],
        ),
      ),
    );
  }

  Widget _endOfHistory() {
    return const Padding(
      padding: EdgeInsets.only(top: 6, bottom: 6),
      child: Center(
        child: Icon(Icons.history_rounded, size: 34, color: Color(0xFFC2BECE)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active order card
// ---------------------------------------------------------------------------

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kFill, width: 1.5),
        boxShadow: cardShadow(opacity: 0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ORDER ID',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: kMagenta,
                            letterSpacing: 0.8)),
                    SizedBox(height: 3),
                    Text('#SR1234 · 8 Items',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: kInk)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                    color: kMagenta, borderRadius: BorderRadius.circular(22)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_shipping_outlined,
                        color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('ON THE WAY',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  for (final g in _activeThumbs) ...[
                    _Thumb(gradient: g, size: 44),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: kFill, borderRadius: BorderRadius.circular(11)),
                    child: const Text('+5',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: kMuted)),
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rs. 850.00',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: kMagenta)),
                  SizedBox(height: 2),
                  Text('Cash Back: Rs. 85.00',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kMagenta)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: kFill),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: Color(0xFFA8A4AE)),
                  SizedBox(width: 7),
                  Text('May 24 · 12:45 PM',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kMuted)),
                ],
              ),
              GestureDetector(
                onTap: () => showToast(context, 'Opening live tracking…'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                      color: kMagenta, borderRadius: BorderRadius.circular(18)),
                  child: const Text('Track Live',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Past order card
// ---------------------------------------------------------------------------

class _PastOrderCard extends StatelessWidget {
  final _PastOrder order;
  final VoidCallback onDetails;
  final VoidCallback onReorder;
  const _PastOrderCard({
    required this.order,
    required this.onDetails,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order ${order.id} · ${order.items} Items',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kInk)),
                    const SizedBox(height: 3),
                    Text(order.date,
                        style: const TextStyle(fontSize: 13, color: kMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                    color: kSuccessBg, borderRadius: BorderRadius.circular(14)),
                child: const Text('DELIVERED',
                    style: TextStyle(
                        color: kSuccess,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  for (final g in order.thumbs) ...[
                    _Thumb(gradient: g, size: 42),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: kCard, borderRadius: BorderRadius.circular(10)),
                    child: Text(order.more,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: kMuted)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rs. ${money(order.total)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: kMagenta)),
                  const SizedBox(height: 2),
                  Text('Earned: Rs. ${money(order.earned)}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kMagenta)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onDetails,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                        color: kCard, borderRadius: BorderRadius.circular(22)),
                    child: const Text('Details',
                        style: TextStyle(
                            color: kInk2,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onReorder,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      gradient: swatch(kMagenta, kMagentaDeep),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text('Reorder',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Thumbnail
// ---------------------------------------------------------------------------

class _Thumb extends StatelessWidget {
  final LinearGradient gradient;
  final double size;
  const _Thumb({required this.gradient, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
    );
  }
}
