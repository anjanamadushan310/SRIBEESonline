/// SRIBEESonline - Saved tab
///
/// Favourited products grid, matching the "SRIBEES Online" prototype:
/// cart-summary card → "Saved Items" title → 2-col grid of saved products
/// (heart toggle, gradient placeholder, "10% Cash Back" badge, Add button).
/// Rendered inside the main shell's IndexedStack (no own Scaffold/header).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/sribees_design.dart';
import '../../../core/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../../products/screens/product_details_screen.dart';

class _SavedItem {
  final String key;
  final String name;
  final String unit;
  final double price;
  const _SavedItem(this.key, this.name, this.unit, this.price);
}

class SavedTab extends ConsumerStatefulWidget {
  const SavedTab({super.key});

  @override
  ConsumerState<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends ConsumerState<SavedTab> {
  // Initially favourited items (prototype `liked` map → bananas, apples, spinach).
  final List<_SavedItem> _items = [
    const _SavedItem('bananas', 'Organic Bananas', '1kg · Fresh from farm', 900),
    const _SavedItem('apples', 'Fuji Apples', 'Pack of 4 · Crisp & sweet', 1350),
    const _SavedItem('spinach', 'Fresh Spinach', '250g · Pesticide free', 450),
  ];

  void _openCart() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  void _unlike(_SavedItem item) {
    setState(() => _items.removeWhere((i) => i.key == item.key));
    showToast(context, 'Removed from saved');
  }

  void _add(_SavedItem item) {
    ref.read(cartProvider.notifier).addItem(
          productId: item.key,
          price: item.price,
          name: item.name,
        );
    showToast(context, '${item.name} added to cart');
  }

  void _open(_SavedItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProductDetailsScreen(
        productKey: item.key,
        name: item.name,
        unit: item.unit,
        price: item.price,
      ),
    ));
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
            'Saved Items',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: kInk,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your curated list of favorite organic produce.',
            style: TextStyle(fontSize: 14, color: kMuted, height: 1.4),
          ),
          const SizedBox(height: 22),
          if (_items.isEmpty)
            _empty()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.66,
              ),
              itemCount: _items.length,
              itemBuilder: (_, i) => _SavedCard(
                item: _items[i],
                onUnlike: () => _unlike(_items[i]),
                onAdd: () => _add(_items[i]),
                onOpen: () => _open(_items[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _empty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 54),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.favorite_border_rounded, size: 44, color: kPlaceholder),
            SizedBox(height: 12),
            Text(
              'No saved items yet',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: kMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final _SavedItem item;
  final VoidCallback onUnlike;
  final VoidCallback onAdd;
  final VoidCallback onOpen;
  const _SavedCard({
    required this.item,
    required this.onUnlike,
    required this.onAdd,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Expanded(
            child: GestureDetector(
              onTap: onOpen,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                        decoration:
                            BoxDecoration(gradient: gradientFor(item.key))),
                    const Align(
                        alignment: Alignment.topLeft, child: CashBackBadge()),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onUnlike,
                        child: Container(
                          width: 31,
                          height: 31,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 8,
                                spreadRadius: -3,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.favorite_rounded,
                              color: kMagenta, size: 17),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 11),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kInk,
                height: 1.2),
          ),
          const SizedBox(height: 2),
          Text(
            item.unit,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: kMuted, height: 1.3),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Rs.${money(item.price)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: kInk),
                ),
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: kMagenta, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Add',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
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
