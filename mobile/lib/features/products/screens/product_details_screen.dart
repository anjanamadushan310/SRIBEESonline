/// SRIBEESonline - Product Details
///
/// Pushed screen matching the "Radiant Editorial" product reference: shared
/// magenta header → image carousel (gradient placeholders) with glass back /
/// share / favourite buttons → floating info card (In Stock, title, rating,
/// 10% Cash Back, price, qty selector) → The Details editorial copy →
/// Nutritional Facts grid → You May Also Like → sticky Add to Cart / Buy Now.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/sribees_design.dart';
import '../../../core/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../../checkout/screens/checkout_screen.dart';

class _Related {
  final String key;
  final String name;
  final double price;
  const _Related(this.key, this.name, this.price);
}

const _related = <_Related>[
  _Related('carrots', 'Organic Carrots', 120),
  _Related('spinach', 'Purple Eggplant', 95),
  _Related('broccoli', 'Crisp Lettuce', 150),
];

const _nutrition = <(String, String)>[
  ('Cals', '18'),
  ('Vit C', '13.7'),
  ('Potass', '237'),
  ('Fiber', '1.2g'),
];

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productKey;
  final String name;
  final String unit;
  final double price;
  final String rating;

  const ProductDetailsScreen({
    super.key,
    required this.productKey,
    required this.name,
    required this.unit,
    required this.price,
    this.rating = '4.8',
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  final _heroController = PageController();
  int _heroPage = 0;
  int _qty = 1;
  bool _liked = false;

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  void _addToCart() {
    ref.read(cartProvider.notifier).addItem(
          productId: widget.productKey,
          price: widget.price,
          name: widget.name,
          quantity: _qty,
        );
    showToast(context, '${widget.name} added to cart');
  }

  void _buyNow() {
    ref.read(cartProvider.notifier).addItem(
          productId: widget.productKey,
          price: widget.price,
          name: widget.name,
          quantity: _qty,
        );
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CheckoutScreen()));
  }

  void _openRelated(_Related r) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProductDetailsScreen(
        productKey: r.key,
        name: r.name,
        unit: 'Fresh from farm',
        price: r.price,
        rating: '4.7',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          SribeesHeader(
            onMenu: () => showToast(context, 'Menu'),
            onCart: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _hero(),
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoCard(),
                                const SizedBox(height: 26),
                                _details(),
                                const SizedBox(height: 36),
                                _nutritionSection(),
                                const SizedBox(height: 36),
                                _relatedSection(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Sticky CTA
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: _ctaBar(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          SribeesBottomNav(selected: -1, onTap: (i) => popToTab(context, ref, i)),
      floatingActionButton: SribeesSparkleFab(
          onTap: () => showToast(context, '✨ AI shopping assistant')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ── Hero carousel ────────────────────────────────────────────────────────
  Widget _hero() {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          PageView.builder(
            controller: _heroController,
            onPageChanged: (p) => setState(() => _heroPage = p),
            itemCount: 3,
            itemBuilder: (_, i) => DecoratedBox(
              decoration: BoxDecoration(gradient: gradientFor(widget.productKey)),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.4, -0.5),
                    radius: 0.9,
                    colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
                child: SizedBox.expand(),
              ),
            ),
          ),
          // Back (left)
          Positioned(
            top: 16,
            left: 20,
            child: _glassButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          // Share + favourite (right)
          Positioned(
            top: 16,
            right: 20,
            child: Row(
              children: [
                _glassButton(
                  icon: Icons.ios_share_rounded,
                  onTap: () => showToast(context, 'Share'),
                ),
                const SizedBox(width: 12),
                _glassButton(
                  icon: _liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  onTap: () {
                    setState(() => _liked = !_liked);
                    showToast(
                        context, _liked ? 'Saved to favorites' : 'Removed');
                  },
                ),
              ],
            ),
          ),
          // Dots
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _heroPage;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withValues(alpha: active ? 1 : 0.5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kBg.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: kMagenta, size: 20),
          ),
        ),
      ),
    );
  }

  // ── Floating info card ───────────────────────────────────────────────────
  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B1C1D).withValues(alpha: 0.10),
            blurRadius: 48,
            spreadRadius: -16,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // In Stock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F7EC),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _Dot(color: Color(0xFF22C55E)),
                SizedBox(width: 8),
                Text('IN STOCK',
                    style: TextStyle(
                        color: Color(0xFF15803D),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.name,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: kInk,
                height: 1.1,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 6),
          Text(widget.unit,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: kMuted)),
          const SizedBox(height: 16),
          // Rating
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF6DF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFF5B301), size: 18),
                    const SizedBox(width: 4),
                    Text(widget.rating,
                        style: const TextStyle(
                            color: Color(0xFF8A6D00),
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text('(1.2k Verified Reviews)',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kMuted)),
            ],
          ),
          const SizedBox(height: 20),
          // Price + qty
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PRICE',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: kMuted.withValues(alpha: 0.7))),
                  const SizedBox(height: 6),
                  const CashBackPill(),
                  const SizedBox(height: 8),
                  Text('Rs. ${money(widget.price)}',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: kMagenta)),
                ],
              ),
              _qtySelector(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtySelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kSurfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _qtyButton(
            icon: Icons.remove,
            filled: false,
            onTap: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
          ),
          SizedBox(
            width: 36,
            child: Text('$_qty',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: kInk)),
          ),
          _qtyButton(
            icon: Icons.add,
            filled: true,
            onTap: () => setState(() => _qty++),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: filled ? kMagenta : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon,
            size: 18, color: filled ? Colors.white : kMuted),
      ),
    );
  }

  // ── The Details ──────────────────────────────────────────────────────────
  Widget _details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            SizedBox(
                width: 32,
                child: Divider(color: kMagenta, thickness: 2, height: 2)),
            SizedBox(width: 12),
            Text('THE DETAILS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: kMuted)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Experience the authentic taste of the countryside with our '
          'handpicked ${widget.name.toLowerCase()}. Ripened naturally under the '
          'sun, these bring a vibrant depth of flavor to any culinary creation.',
          style: const TextStyle(
              fontSize: 15, height: 1.8, color: kInk, letterSpacing: 0.15),
        ),
        const SizedBox(height: 14),
        const Text(
          'Grown with sustainable farming practices and zero synthetic '
          'pesticides, they are as healthy as they are delicious. Perfect for '
          'garden-fresh salads, slow-cooked sauces, or traditional hearty '
          'curries.',
          style: TextStyle(
              fontSize: 15, height: 1.8, color: kMuted, letterSpacing: 0.15),
        ),
      ],
    );
  }

  // ── Nutritional Facts ────────────────────────────────────────────────────
  Widget _nutritionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text('NUTRITIONAL FACTS',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: kInk)),
            SizedBox(width: 6),
            Padding(
              padding: EdgeInsets.only(bottom: 1),
              child: Text('(per 100g)',
                  style: TextStyle(fontSize: 10, color: kMuted)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var i = 0; i < _nutrition.length; i++) ...[
              Expanded(
                  child: _nutritionTile(
                      _nutrition[i].$1, _nutrition[i].$2)),
              if (i < _nutrition.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }

  Widget _nutritionTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: kSurfaceLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kMuted)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kMagenta)),
        ],
      ),
    );
  }

  // ── You May Also Like ────────────────────────────────────────────────────
  Widget _relatedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('You May Also Like',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kInk)),
            GestureDetector(
              onTap: () => showToast(context, 'View all'),
              child: const Text('VIEW ALL',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: kMagenta)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _related.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => _relatedCard(_related[i]),
          ),
        ),
      ],
    );
  }

  Widget _relatedCard(_Related r) {
    return GestureDetector(
      onTap: () => _openRelated(r),
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(28),
          boxShadow: cardShadow(opacity: 0.14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              padding: const EdgeInsets.all(8),
              color: kSurfaceContainer,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: gradientFor(r.key)),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: kInk)),
                  const SizedBox(height: 4),
                  Text('Rs. ${money(r.price)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kMagenta)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sticky CTA ───────────────────────────────────────────────────────────
  Widget _ctaBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B1C1D).withValues(alpha: 0.15),
                blurRadius: 48,
                spreadRadius: -12,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _addToCart,
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kSurfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Add to Cart',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: kInk2)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: _buyNow,
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kMagenta,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: kMagenta.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: -6,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Buy Now',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        SizedBox(width: 8),
                        Icon(Icons.shopping_bag_outlined,
                            color: Colors.white, size: 20),
                      ],
                    ),
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

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
