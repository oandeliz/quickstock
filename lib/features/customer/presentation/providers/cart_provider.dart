import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:quickstock/core/database/app_database.dart';

part 'cart_provider.g.dart';

class CartItem {
  final ProductsTableData product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  CartItem copyWith({ProductsTableData? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  List<CartItem> build() => [];

  void addProduct(ProductsTableData product) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final updated = List<CartItem>.from(state);
      updated[existingIndex] = updated[existingIndex].copyWith(
        quantity: updated[existingIndex].quantity + 1,
      );
      state = updated;
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      state = state.where((item) => item.product.id != productId).toList();
      return;
    }
    final updated = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
    state = updated;
  }

  void clearCart() {
    state = [];
  }

  double get total {
    return state.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }
}
