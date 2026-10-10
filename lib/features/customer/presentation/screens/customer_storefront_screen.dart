import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickstock/features/inventory/presentation/providers/inventory_notifier.dart';
import 'package:quickstock/features/customer/presentation/providers/cart_provider.dart';
import 'package:quickstock/features/customer/presentation/widgets/cart_checkout_sheet.dart';

class CustomerStorefrontScreen extends ConsumerWidget {
  const CustomerStorefrontScreen({super.key});

  void _showCameraMock(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Visual Search', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visual Search coming in Day 7!')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visual Search coming in Day 7!')));
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartCheckoutSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);
    final cartItems = ref.watch(cartNotifierProvider);
    final cartCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickStock', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Sign In / Register'),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _showCartSheet(context),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: theme.colorScheme.error, shape: BoxShape.circle),
                    child: Text(
                      '$cartCount',
                      style: TextStyle(color: theme.colorScheme.onError, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              hintText: 'Search products...',
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  tooltip: 'Visual Search',
                  onPressed: () => _showCameraMock(context),
                ),
              ],
              onChanged: (value) {
                ref.read(productSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
        ),
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products found.'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final isLowStock = product.stockCount < 5 && product.stockCount > 0;
                final isOutOfStock = product.stockCount <= 0;

                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.inventory_2, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isOutOfStock
                                        ? theme.colorScheme.errorContainer
                                        : isLowStock
                                            ? Colors.orange.shade100
                                            : theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isOutOfStock
                                        ? 'Out of Stock'
                                        : isLowStock
                                            ? 'Low Stock'
                                            : 'In Stock',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isOutOfStock
                                          ? theme.colorScheme.onErrorContainer
                                          : isLowStock
                                              ? Colors.orange.shade900
                                              : theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: isOutOfStock
                                  ? null
                                  : () {
                                      ref.read(cartNotifierProvider.notifier).addProduct(product);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${product.title} added to cart!'),
                                          duration: const Duration(seconds: 2),
                                          action: SnackBarAction(
                                            label: 'View Cart',
                                            onPressed: () => _showCartSheet(context),
                                          ),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.add_shopping_cart, size: 16),
                              label: const Text('Add'),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
