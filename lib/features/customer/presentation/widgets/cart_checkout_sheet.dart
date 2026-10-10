import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickstock/core/database/app_database.dart';
import 'package:quickstock/core/database/tables/orders_table.dart';
import 'package:quickstock/core/providers/database_provider.dart';
import 'package:quickstock/features/customer/presentation/providers/cart_provider.dart';
import 'package:quickstock/features/orders/presentation/widgets/delivery_qr_view.dart';


class CartCheckoutSheet extends ConsumerStatefulWidget {
  const CartCheckoutSheet({super.key});

  @override
  ConsumerState<CartCheckoutSheet> createState() => _CartCheckoutSheetState();
}

class _CartCheckoutSheetState extends ConsumerState<CartCheckoutSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _generateToken() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final randomStr = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    return 'QS-$randomStr';
  }

  Future<void> _placeOrder() async {
    final cart = ref.read(cartNotifierProvider);
    if (cart.isEmpty) return;

    final db = ref.read(appDatabaseProvider);
    final total = ref.read(cartNotifierProvider.notifier).total;
    final token = _generateToken();
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    await db.into(db.ordersTable).insert(
          OrdersTableCompanion.insert(
            id: orderId,
            customerId: 'GUEST',
            status: OrderStatus.pending,
            deliveryToken: token,
            totalAmount: total,
          ),
        );

    ref.read(cartNotifierProvider.notifier).clearCart();
    
    if (!mounted) return;
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Order Placed Successfully! 🎉', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Show this QR code to the driver upon delivery.', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                DeliveryQrView(orderId: orderId, deliveryToken: token),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Want to track this order later? Create a password to save your profile.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartNotifierProvider);
    final total = ref.read(cartNotifierProvider.notifier).total;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              const Text('Your Cart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text('Your cart is empty'))
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: cartItems.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      ref.read(cartNotifierProvider.notifier).updateQuantity(item.product.id, item.quantity - 1);
                                    },
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      ref.read(cartNotifierProvider.notifier).updateQuantity(item.product.id, item.quantity + 1);
                                    },
                                  ),
                                ],
                              )
                            ],
                          );
                        },
                      ),
              ),
              if (cartItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
              if (cartItems.isNotEmpty)
                Expanded(
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: theme.colorScheme.primary,
                        tabs: const [
                          Tab(text: 'Guest Checkout'),
                          Tab(text: 'Sign In'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                TextField(decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                                const SizedBox(height: 12),
                                TextField(decoration: InputDecoration(labelText: 'Phone Number / WhatsApp', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                                const SizedBox(height: 12),
                                TextField(
                                  maxLines: 3,
                                  decoration: InputDecoration(labelText: 'Drop-off Address / Notes', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                                ),
                                const SizedBox(height: 24),
                                FilledButton(
                                  onPressed: _placeOrder,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Confirm & Place Order', style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                            ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                TextField(decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                                const SizedBox(height: 12),
                                TextField(
                                  obscureText: true,
                                  decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                                ),
                                const SizedBox(height: 24),
                                FilledButton(
                                  onPressed: _placeOrder,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Sign In & Place Order', style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
