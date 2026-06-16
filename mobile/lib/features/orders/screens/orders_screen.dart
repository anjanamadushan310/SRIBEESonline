/// SRIBEESonline - Orders Screen
///
/// Design:
///   • Shared AppBar (SRIBEES Online + cart badge)
///   • Cart summary card
///   • "Your Orders" title + subtitle
///   • Tab chips: Active Orders | Past Orders | Return Orders
///   • Active Orders section: order card with status, images, track live
///   • Past Orders section: order card with details + reorder buttons
///   • Bottom nav (ORDERS tab active)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/cart_provider.dart';
import '../../cart/models/cart_model.dart';
import '../../cart/screens/cart_screen.dart';

const _pink = Color(0xFFB5175A);
const _pinkLight = Color(0xFFFFECF3);
const _green = Color(0xFF1B9E4B);
const _greenBg = Color(0xFFE8F5EE);

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

enum _OrderStatus { onTheWay, delivered }

class _OrderItem {
  final String id;
  final int itemCount;
  final _OrderStatus status;
  final double total;
  final String date;
  final List<String> imageUrls;

  const _OrderItem({
    required this.id,
    required this.itemCount,
    required this.status,
    required this.total,
    required this.date,
    required this.imageUrls,
  });

  double get cashBack => total * 0.10;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _foodImages = [
  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=120',
  'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=120',
  'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=120',
  'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=120',
  'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=120',
];

final _activeOrders = [
  _OrderItem(
    id: '#SR1234',
    itemCount: 8,
    status: _OrderStatus.onTheWay,
    total: 850.00,
    date: 'May 24, 2024 • 12:45 PM',
    imageUrls: _foodImages.sublist(0, 3),
  ),
];

final _pastOrders = [
  _OrderItem(
    id: '#SR0982',
    itemCount: 5,
    status: _OrderStatus.delivered,
    total: 720.00,
    date: 'May 20, 2024',
    imageUrls: _foodImages.sublist(0, 2),
  ),
  _OrderItem(
    id: '#SR0744',
    itemCount: 12,
    status: _OrderStatus.delivered,
    total: 1250.00,
    date: 'May 15, 2024',
    imageUrls: _foodImages.sublist(1, 3),
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _tabIndex = 0; // 0=Active 1=Past 2=Return

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartTotal = cart.items.fold<double>(0, (s, i) => s + i.total);
    final itemCount = cart.itemCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context, cartTotal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cart summary card
            _CartSummaryCard(
              itemCount: itemCount,
              total: cartTotal,
              onViewCart: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 22, 16, 4),
              child: Text(
                'Your Orders',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tracking your culinary journey',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 18),

            // Tab chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _TabChip(
                      label: 'Active Orders',
                      active: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0)),
                  const SizedBox(width: 8),
                  _TabChip(
                      label: 'Past Orders',
                      active: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1)),
                  const SizedBox(width: 8),
                  _TabChip(
                      label: 'Return Orders',
                      active: _tabIndex == 2,
                      onTap: () => setState(() => _tabIndex = 2)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tab content
            if (_tabIndex == 0) _ActiveOrdersSection(),
            if (_tabIndex == 1) _PastOrdersSection(),
            if (_tabIndex == 2)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Text('No return orders',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 15)),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        selected: 2,
        onTap: (i) => _onNavTap(context, i),
      ),
      floatingActionButton: _AICartFab(onTap: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _onNavTap(BuildContext context, int i) {
    if (i == 2) return; // already here
    Navigator.of(context).pop();
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, double cartTotal) {
    return PreferredSize(
      preferredSize:
          Size.fromHeight(64 + MediaQuery.of(context).padding.top),
      child: Container(
        color: _pink,
        padding: const EdgeInsets.fromLTRB(4, 0, 8, 12),
        child: SafeArea(
          bottom: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.menu_rounded,
                    color: Colors.white, size: 26),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
              const Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('SRIBEES',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5)),
                    SizedBox(width: 5),
                    Text('Online',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_cart_rounded,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        'Rs${cartTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active Orders section
// ---------------------------------------------------------------------------

class _ActiveOrdersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('Active Orders',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A))),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _pinkLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_activeOrders.length} ITEM${_activeOrders.length == 1 ? '' : 'S'}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _pink),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._activeOrders
            .map((o) => _ActiveOrderCard(order: o)),
        const SizedBox(height: 24),
        // Past orders header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Past Orders',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A))),
        ),
        const SizedBox(height: 12),
        ..._pastOrders
            .map((o) => _PastOrderCard(order: o)),
        const _EndOfHistory(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Past Orders section (standalone tab)
// ---------------------------------------------------------------------------

class _PastOrdersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Past Orders',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A))),
        ),
        const SizedBox(height: 12),
        ..._pastOrders.map((o) => _PastOrderCard(order: o)),
        const _EndOfHistory(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Active order card
// ---------------------------------------------------------------------------

class _ActiveOrderCard extends StatelessWidget {
  final _OrderItem order;
  const _ActiveOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ORDER ID',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _pink,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(
                    '${order.id} • ${order.itemCount} Items',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A)),
                  ),
                ],
              ),
              const Spacer(),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _pinkLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.delivery_dining_rounded,
                        color: _pink, size: 16),
                    const SizedBox(width: 4),
                    const Text('ON THE\nWAY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _pink,
                            height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Product images row
          Row(
            children: [
              ...order.imageUrls.take(3).map(
                    (url) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            color: const Color(0xFFF0F0F0),
                            child: const Icon(Icons.fastfood,
                                color: Colors.grey, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
              if (order.itemCount > 3)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+${order.itemCount - 3}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF666666)),
                    ),
                  ),
                ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs.\n${order.total.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _pink,
                        height: 1.2),
                  ),
                  Text(
                    'Cash Back: Rs. ${order.cashBack.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _pink),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),

          // Date + Track Live
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                order.date,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Track Live',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _pink,
                      decoration: TextDecoration.underline,
                      decorationColor: _pink),
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
  final _OrderItem order;
  const _PastOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  '${order.id} • ${order.itemCount} Items',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _greenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DELIVERED',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(order.date,
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 12),

          // Images + price
          Row(
            children: [
              ...order.imageUrls.take(2).map(
                    (url) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            color: const Color(0xFFF0F0F0),
                          ),
                        ),
                      ),
                    ),
                  ),
              if (order.itemCount > 2)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+${order.itemCount - 2}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF666666)),
                    ),
                  ),
                ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _pink),
                  ),
                  Text(
                    'Cash Back Earned: Rs. ${order.cashBack.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _pink),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Details + Reorder buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1A1A),
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: const Text('Details',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: const Text('Reorder',
                      style: TextStyle(fontWeight: FontWeight.w700)),
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
// End of history
// ---------------------------------------------------------------------------

class _EndOfHistory extends StatelessWidget {
  const _EndOfHistory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text('End of order history',
              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab chip
// ---------------------------------------------------------------------------

class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? _pink : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: active ? _pink : const Color(0xFFDDDDDD),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: _pink.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets (same as SavedScreen — consider extracting to shared file)
// ---------------------------------------------------------------------------

class _CartSummaryCard extends StatelessWidget {
  final int itemCount;
  final double total;
  final VoidCallback onViewCart;

  const _CartSummaryCard(
      {required this.itemCount,
      required this.total,
      required this.onViewCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _pinkLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: _pink, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$itemCount Item${itemCount == 1 ? '' : 's'} in your cart',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs. ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _pink),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onViewCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: _pink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 10),
              textStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
            child: const Text('View\nCart', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 62,
      padding: EdgeInsets.zero,
      notchMargin: 6,
      shape: const CircularNotchedRectangle(),
      color: _pink,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
              icon: Icons.home_rounded,
              label: 'HOME',
              index: 0,
              selected: selected,
              onTap: onTap),
          _NavItem(
              icon: Icons.favorite_border_rounded,
              label: 'SAVED',
              index: 1,
              selected: selected,
              onTap: onTap),
          const SizedBox(width: 56),
          _NavItem(
              icon: Icons.receipt_long_outlined,
              label: 'ORDERS',
              index: 2,
              selected: selected,
              onTap: onTap),
          _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'PROFILE',
              index: 3,
              selected: selected,
              onTap: onTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selected;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == selected;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 24,
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.65)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AICartFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AICartFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.auto_awesome_rounded,
            color: Colors.white, size: 28),
      ),
    );
  }
}
