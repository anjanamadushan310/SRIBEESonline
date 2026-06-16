/// SRIBEESonline - Saved / Wishlist Screen
///
/// Design:
///   • Shared AppBar (SRIBEES Online + cart badge)
///   • Cart summary card (item count + total + View Cart)
///   • "Saved Items" title + subtitle
///   • 2-column product grid with cash-back badge, heart, Add to Cart
///   • Bottom nav (SAVED tab active)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/cart_provider.dart';
import '../../cart/models/cart_model.dart';
import '../../cart/screens/cart_screen.dart';

const _pink = Color(0xFFB5175A);
const _pinkLight = Color(0xFFFFECF3);

// ---------------------------------------------------------------------------
// Mock saved products
// ---------------------------------------------------------------------------

class _SavedItem {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  static const cashBackPct = 10;

  const _SavedItem(this.name, this.description, this.price, this.imageUrl);
}

final _savedItems = [
  const _SavedItem(
    'Organic Bananas',
    '1kg • Fresh from farm',
    120.00,
    'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=400',
  ),
  const _SavedItem(
    'Fuji Apples',
    'Pack of 4 • Sweet & Crunchy',
    450.00,
    'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400',
  ),
  const _SavedItem(
    'Garden Carrots',
    '500g • Homegrown Quality',
    85.00,
    'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400',
  ),
  const _SavedItem(
    'Leafy Spinach',
    '250g • Pesticide Free',
    60.00,
    'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400',
  ),
  const _SavedItem(
    'Strawberries',
    'Box • Farm Picked Today',
    850.00,
    'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400',
  ),
];

// ---------------------------------------------------------------------------

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  final Set<String> _saved = {
    for (final i in _savedItems) i.name
  };

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartTotal = cart.items.fold<double>(0, (s, i) => s + i.total);
    final itemCount = cart.itemCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context, cartTotal),
      body: Column(
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
            padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Saved Items',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Manage your curated list of favorite organic produce.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Grid
          Expanded(
            child: _saved.isEmpty
                ? _EmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: _savedItems.length,
                    itemBuilder: (_, i) {
                      final item = _savedItems[i];
                      return _SavedProductCard(
                        item: item,
                        isSaved: _saved.contains(item.name),
                        onToggleSave: () => setState(() {
                          if (_saved.contains(item.name)) {
                            _saved.remove(item.name);
                          } else {
                            _saved.add(item.name);
                          }
                        }),
                        onAddToCart: () {
                          ref.read(cartProvider.notifier).addItem(
                                productId: item.name.hashCode.toString(),
                                price: item.price,
                                name: item.name,
                                imageUrl: item.imageUrl,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${item.name} added to cart'),
                            backgroundColor: _pink,
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        selected: 1,
        onTap: (i) => _onNavTap(context, i),
      ),
      floatingActionButton: _AICartFab(onTap: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _onNavTap(BuildContext context, int i) {
    if (i == 1) return; // already here
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
// Saved product card
// ---------------------------------------------------------------------------

class _SavedProductCard extends StatelessWidget {
  final _SavedItem item;
  final bool isSaved;
  final VoidCallback onToggleSave;
  final VoidCallback onAddToCart;

  const _SavedProductCard({
    required this.item,
    required this.isSaved,
    required this.onToggleSave,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + badges
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.network(
                  item.imageUrl,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    color: const Color(0xFFF0F0F0),
                    child: Icon(Icons.image_outlined,
                        color: Colors.grey[400], size: 36),
                  ),
                ),
              ),
              // Cash back badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _pink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_SavedItem.cashBackPct}% Cash Back',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              // Heart button
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: onToggleSave,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: _pink,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Rs.\n${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A)),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  Text(
                    item.description,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[500]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Add to Cart button
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: onAddToCart,
                      icon: const Icon(Icons.shopping_cart_outlined,
                          size: 15),
                      label: const Text('Add to Cart',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded,
              size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No saved items',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text('Tap ♡ on any product to save it',
              style: TextStyle(fontSize: 14, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cart summary card (shared across screens)
// ---------------------------------------------------------------------------

class _CartSummaryCard extends StatelessWidget {
  final int itemCount;
  final double total;
  final VoidCallback onViewCart;

  const _CartSummaryCard({
    required this.itemCount,
    required this.total,
    required this.onViewCart,
  });

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
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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

// ---------------------------------------------------------------------------
// Bottom Nav (shared)
// ---------------------------------------------------------------------------

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
              icon: Icons.favorite_rounded,
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
        child:
            const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
