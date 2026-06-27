/// SRIBEESonline - Cart Provider
///
/// Local / in-memory shopping cart state (Riverpod). The previous version
/// depended on a `CartRepository` source file that was never committed, which
/// broke clean builds. This implementation keeps the same public API the UI
/// relies on (`items`, `itemCount`, `addItem`, `updateQuantity`, `removeItem`,
/// `clearCart`) and computes totals locally. Wire a backend repository back in
/// here when the server cart sync is ready.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cart/models/cart_model.dart';

// Flat delivery fee applied once the cart has items (matches the cart UI).
const double _deliveryFee = 350;

// =============================================================================
// Cart State
// =============================================================================

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;
  final CartTotals? totals;
  final AppliedCoupon? coupon;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.totals,
    this.coupon,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  double get subtotal => totals?.subtotal ?? 0;

  double get total => totals?.total ?? 0;

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
    CartTotals? totals,
    AppliedCoupon? coupon,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      totals: totals ?? this.totals,
      coupon: coupon ?? this.coupon,
    );
  }
}

// =============================================================================
// Providers
// =============================================================================

final cartProvider =
    StateNotifierProvider<CartNotifier, CartState>((ref) => CartNotifier());

/// Cart item count (for badge).
final cartItemCountProvider =
    Provider<int>((ref) => ref.watch(cartProvider).itemCount);

/// Cart total (for display).
final cartTotalProvider =
    Provider<double>((ref) => ref.watch(cartProvider).total);

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState()) {
    _recalculateTotals();
  }

  /// Add item to cart (or bump quantity if it already exists).
  void addItem({
    required String productId,
    String? variantId,
    int quantity = 1,
    required double price,
    required String name,
    String? imageUrl,
  }) {
    final existingIndex = state.items.indexWhere(
      (item) => item.productId == productId && item.variantId == variantId,
    );

    final items = [...state.items];
    if (existingIndex >= 0) {
      final existing = items[existingIndex];
      items[existingIndex] =
          existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      items.add(CartItem(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        price: price,
        name: name,
        imageUrl: imageUrl,
      ));
    }

    state = state.copyWith(items: items);
    _recalculateTotals();
  }

  /// Update an item's quantity (removes it when quantity <= 0).
  void updateQuantity({
    required String productId,
    String? variantId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      removeItem(productId: productId, variantId: variantId);
      return;
    }

    final items = state.items.map((item) {
      if (item.productId == productId && item.variantId == variantId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: items);
    _recalculateTotals();
  }

  /// Remove an item from the cart.
  void removeItem({required String productId, String? variantId}) {
    final items = state.items
        .where((item) =>
            !(item.productId == productId && item.variantId == variantId))
        .toList();

    state = state.copyWith(items: items);
    _recalculateTotals();
  }

  /// Empty the cart.
  void clearCart() {
    state = const CartState();
    _recalculateTotals();
  }

  void _recalculateTotals() {
    final subtotal = state.items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final shipping = subtotal > 0 ? _deliveryFee : 0.0;

    state = state.copyWith(
      totals: CartTotals(
        subtotal: subtotal,
        shipping: shipping,
        total: subtotal + shipping,
      ),
    );
  }
}
