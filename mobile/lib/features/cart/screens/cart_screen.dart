/// SRIBEESonline - Cart Screen
///
/// Design:
///   • Custom header (pink back button + title + subtitle)
///   • Select-All checkbox row
///   • Scrollable item list (checkbox · image · name · qty stepper · price)
///   • "MORE ITEMS BELOW" hint when list overflows
///   • Sticky summary card (subtotal · delivery · profit · grand total)
///   • Pink Checkout button
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/cart_provider.dart';
import '../models/cart_model.dart';

const _pink = Color(0xFFB5175A);
const _green = Color(0xFF1B9E4B);
const _greenBg = Color(0xFFE8F5EE);
const _bg = Color(0xFFFFFFFF);

/// Fixed delivery fee (Rs.)
const _deliveryFee = 350.0;

/// Cash-back rate applied to subtotal (4.5 %)
const _cashBackRate = 0.045;

// ---------------------------------------------------------------------------

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final Set<String> _selected = {};
  bool _allSelected = true;

  @override
  void initState() {
    super.initState();
    // Pre-select all items once the cart loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final items = ref.read(cartProvider).items;
      setState(() {
        _selected.addAll(items.map((i) => i.itemKey));
        _allSelected = true;
      });
    });
  }

  void _toggleAll(bool? value) {
    final items = ref.read(cartProvider).items;
    setState(() {
      _allSelected = value ?? false;
      if (_allSelected) {
        _selected.addAll(items.map((i) => i.itemKey));
      } else {
        _selected.clear();
      }
    });
  }

  void _toggleItem(String key, bool? value) {
    final items = ref.read(cartProvider).items;
    setState(() {
      if (value == true) {
        _selected.add(key);
      } else {
        _selected.remove(key);
      }
      _allSelected = _selected.length == items.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final items = cart.items;

    // Subtotal of selected items only
    final subtotal = items
        .where((i) => _selected.contains(i.itemKey))
        .fold<double>(0, (s, i) => s + i.total);

    final cashBack = subtotal * _cashBackRate;
    final grandTotal = subtotal + (subtotal > 0 ? _deliveryFee : 0);
    final selectedCount =
        items.where((i) => _selected.contains(i.itemKey)).fold<int>(
              0,
              (s, i) => s + i.quantity,
            );

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Custom Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: _pink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Cart',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review your items before proceeding to checkout.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // ── Select All ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _PinkCheckbox(
                    value: _allSelected,
                    onChanged: _toggleAll,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Select All Items',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // ── Items list ─────────────────────────────────────────────────
            Expanded(
              child: cart.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _pink))
                  : items.isEmpty
                      ? _EmptyCart(onShop: () => Navigator.of(context).pop())
                      : _ItemList(
                          items: items,
                          selected: _selected,
                          onToggle: _toggleItem,
                          onIncrement: (item) =>
                              ref.read(cartProvider.notifier).updateQuantity(
                                    productId: item.productId,
                                    variantId: item.variantId,
                                    quantity: item.quantity + 1,
                                  ),
                          onDecrement: (item) =>
                              ref.read(cartProvider.notifier).updateQuantity(
                                    productId: item.productId,
                                    variantId: item.variantId,
                                    quantity: item.quantity - 1,
                                  ),
                        ),
            ),

            // ── Summary ────────────────────────────────────────────────────
            if (items.isNotEmpty)
              _CartSummary(
                subtotal: subtotal,
                deliveryFee: subtotal > 0 ? _deliveryFee : 0,
                cashBack: cashBack,
                grandTotal: grandTotal,
                selectedCount: selectedCount,
                canCheckout: _selected.isNotEmpty,
                onCheckout: () {
                  // TODO: navigate to checkout screen
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Items list
// ---------------------------------------------------------------------------

class _ItemList extends StatelessWidget {
  final List<CartItem> items;
  final Set<String> selected;
  final void Function(String key, bool? value) onToggle;
  final void Function(CartItem) onIncrement;
  final void Function(CartItem) onDecrement;

  const _ItemList({
    required this.items,
    required this.selected,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      itemCount: items.length + (items.length > 3 ? 1 : 0),
      separatorBuilder: (_, i) => i == items.length - 1
          ? const SizedBox.shrink()
          : const Divider(
              height: 1, thickness: 1, indent: 70, color: Color(0xFFF0F0F0)),
      itemBuilder: (_, i) {
        // "More items below" hint between item 2 and 3
        if (i == items.length && items.length > 3) {
          return const _MoreItemsHint();
        }
        final item = items[i];
        return _CartItemTile(
          item: item,
          isSelected: selected.contains(item.itemKey),
          onToggle: (v) => onToggle(item.itemKey, v),
          onIncrement: () => onIncrement(item),
          onDecrement: () => onDecrement(item),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Single cart item tile
// ---------------------------------------------------------------------------

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final bool isSelected;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemTile({
    required this.item,
    required this.isSelected,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox
          _PinkCheckbox(value: isSelected, onChanged: onToggle),
          const SizedBox(width: 10),

          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgPlaceholder(),
                  )
                : _imgPlaceholder(),
          ),
          const SizedBox(width: 12),

          // Name + quantity stepper
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QtyButton(
                        icon: Icons.remove,
                        onTap: onDecrement),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _QtyButton(
                        icon: Icons.add,
                        onTap: onIncrement),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Price
          Text(
            'Rs. ${item.total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        width: 68,
        height: 68,
        color: const Color(0xFFF5F5F5),
        child: const Icon(Icons.image_outlined, color: Color(0xFFCCCCCC), size: 30),
      );
}

// ---------------------------------------------------------------------------
// Quantity button
// ---------------------------------------------------------------------------

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF333333)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "More items below" hint
// ---------------------------------------------------------------------------

class _MoreItemsHint extends StatelessWidget {
  const _MoreItemsHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Text(
            'MORE ITEMS BELOW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 2),
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 20, color: Colors.grey[400]),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cart summary (sticky bottom)
// ---------------------------------------------------------------------------

class _CartSummary extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double cashBack;
  final double grandTotal;
  final int selectedCount;
  final bool canCheckout;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.subtotal,
    required this.deliveryFee,
    required this.cashBack,
    required this.grandTotal,
    required this.selectedCount,
    required this.canCheckout,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          _SummaryRow(
            label: 'Subtotal ($selectedCount item${selectedCount == 1 ? '' : 's'})',
            value: 'Rs. ${subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 6),

          // Delivery fee
          _SummaryRow(
            label: 'Delivery Fee',
            value: 'Rs. ${deliveryFee.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 10),

          // Your Profit card
          if (cashBack > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _greenBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.savings_outlined, color: _green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Profit!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _green,
                          ),
                        ),
                        Text(
                          'Rs. ${cashBack.toStringAsFixed(2)} Cash Back saved on this order',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+ Rs. ${cashBack.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _green,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                'Rs. ${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canCheckout ? onCheckout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pink,
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Checkout'),
            ),
          ),

          // Bottom safe-area spacer
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty cart
// ---------------------------------------------------------------------------

class _EmptyCart extends StatelessWidget {
  final VoidCallback onShop;
  const _EmptyCart({required this.onShop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Your cart is empty',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text('Add items from the home screen',
              style: TextStyle(fontSize: 14, color: Colors.grey[400])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onShop,
            style: ElevatedButton.styleFrom(
              backgroundColor: _pink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: const Text('Shop Now',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pink checkbox
// ---------------------------------------------------------------------------

class _PinkCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _PinkCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: _pink,
        checkColor: Colors.white,
        side: BorderSide(
            color: value ? _pink : Colors.grey[400]!, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
