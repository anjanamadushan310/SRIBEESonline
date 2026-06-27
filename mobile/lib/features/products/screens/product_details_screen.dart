/// SRIBEESonline - Product Details
///
/// Pushed screen matching the prototype: full-bleed gradient hero with parallax
/// on scroll, back + heart, a rounded sheet with name/unit + rating, weight
/// selector, expandable detail accordions, and a sticky qty + Add bar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/sribees_design.dart';
import '../../../core/providers/cart_provider.dart';

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
  final _scroll = ScrollController();
  int _weight = 1; // 250g / 500g / 1kg
  int _qty = 1;
  bool _liked = false;
  final List<bool> _open = [true, false, false];
  double _offset = 0;

  static const _weights = ['250g', '500g', '1kg'];
  static const _accordions = [
    (
      'Nutrition Facts',
      'Rich in fiber, potassium and vitamin C. Approximately 89 kcal per 100g. '
          'No added sugars or preservatives — just clean, natural goodness.'
    ),
    (
      'Storage & Freshness',
      'Keep refrigerated between 2–6°C. Best consumed within 5 days of delivery. '
          'Store away from direct sunlight to preserve freshness.'
    ),
    (
      'Delivery Info',
      'Free delivery on orders above Rs. 2,000. Same-day delivery available '
          'before 2 PM. Sealed in eco-friendly, recyclable packaging.'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => setState(() => _offset = _scroll.offset));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _add() {
    ref.read(cartProvider.notifier).addItem(
          productId: widget.productKey,
          price: widget.price,
          name: widget.name,
          quantity: _qty,
        );
    showToast(context, '${widget.name} added to cart');
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final parallax = (_offset * 0.4).clamp(0.0, 400.0);
    final scale = 1 + (_offset.clamp(0, 200) * 0.0007);
    final total = widget.price * _qty;

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // Scrolling content
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero (parallax)
                  SizedBox(
                    height: 330,
                    child: ClipRect(
                      child: Transform.translate(
                        offset: Offset(0, parallax),
                        child: Transform.scale(
                          scale: scale,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: gradientFor(widget.productKey),
                            ),
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment(-0.4, -0.5),
                                  radius: 0.8,
                                  colors: [Color(0x38FFFFFF), Color(0x00FFFFFF)],
                                ),
                              ),
                              child: SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Sheet
                  Transform.translate(
                    offset: const Offset(0, -26),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: kBg,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 42,
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0DDE4),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: kInk,
                                        height: 1.15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(widget.unit,
                                        style: const TextStyle(
                                            fontSize: 13, color: kMuted)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                    color: kMagentaTint,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: kMagenta, size: 16),
                                    const SizedBox(width: 4),
                                    Text(widget.rating,
                                        style: const TextStyle(
                                            color: kMagenta,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          const _Label('Select Weight'),
                          const SizedBox(height: 12),
                          Row(
                            children: List.generate(_weights.length, (i) {
                              final active = i == _weight;
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: i < _weights.length - 1 ? 10 : 0),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _weight = i),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 11),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: active ? kMagenta : kCard,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: active ? kMagenta : kBorder,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        _weights[i],
                                        style: TextStyle(
                                          color: active ? Colors.white : kInk,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                          const _Label('Product Details'),
                          const SizedBox(height: 12),
                          ...List.generate(_accordions.length, (i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _Accordion(
                                title: _accordions[i].$1,
                                body: _accordions[i].$2,
                                open: _open[i],
                                onToggle: () =>
                                    setState(() => _open[i] = !_open[i]),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  iconColor: kInk,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                _circleButton(
                  icon: _liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: kMagenta,
                  onTap: () {
                    setState(() => _liked = !_liked);
                    showToast(context,
                        _liked ? 'Saved to favorites' : 'Removed');
                  },
                ),
              ],
            ),
          ),

          // Sticky bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: kCard,
                border: Border(top: BorderSide(color: kBorder)),
              ),
              padding: EdgeInsets.fromLTRB(
                  18, 14, 18, 18 + MediaQuery.of(context).padding.bottom),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorder, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(
                              () => _qty = _qty > 1 ? _qty - 1 : 1),
                          child: const Icon(Icons.remove,
                              size: 18, color: kInk),
                        ),
                        SizedBox(
                          width: 34,
                          child: Text('$_qty',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: kInk)),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _qty++),
                          child: const Icon(Icons.add,
                              size: 18, color: kMagenta),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: _add,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kMagenta,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text('Add · Rs.${money(total)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
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

  Widget _circleButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: -4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: kInk),
    );
  }
}

class _Accordion extends StatelessWidget {
  final String title;
  final String body;
  final bool open;
  final VoidCallback onToggle;
  const _Accordion({
    required this.title,
    required this.body,
    required this.open,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kFill, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kInk)),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: kMuted, size: 22),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                body,
                style: const TextStyle(
                    fontSize: 13, height: 1.55, color: kMuted),
              ),
            ),
            crossFadeState:
                open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
