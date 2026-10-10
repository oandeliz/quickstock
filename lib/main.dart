import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/orders/presentation/widgets/delivery_qr_view.dart';
import 'features/delivery/presentation/widgets/delivery_scanner_view.dart';
import 'features/inventory/presentation/providers/inventory_notifier.dart';

void main() {
  runApp(const ProviderScope(child: QuickStockPreviewApp()));
}

class QuickStockPreviewApp extends StatelessWidget {
  const QuickStockPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickStock Preview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DevHarnessScreen(),
    );
  }
}

class DevHarnessScreen extends ConsumerStatefulWidget {
  const DevHarnessScreen({super.key});

  @override
  ConsumerState<DevHarnessScreen> createState() => _DevHarnessScreenState();
}

class _DevHarnessScreenState extends ConsumerState<DevHarnessScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _InventoryPreviewTab(),
      const _QrPreviewTab(),
      const _ScannerPreviewTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_currentIndex) {
          0 => 'Day 3: Inventory & Riverpod',
          1 => 'Day 4: Customer QR Code',
          _ => 'Day 4: Driver Camera Scanner',
        }),
        centerTitle: true,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_outlined),
            selectedIcon: Icon(Icons.qr_code),
            label: 'QR View',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Camera Scanner',
          ),
        ],
      ),
    );
  }
}

class _InventoryPreviewTab extends ConsumerWidget {
  const _InventoryPreviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredProductsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: SearchBar(
            hintText: 'Search products in real time...',
            leading: const Icon(Icons.search),
            onChanged: (val) {
              ref.read(productSearchQueryProvider.notifier).update(val);
            },
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Test Item to Drift DB'),
                    onPressed: () {
                      ref
                          .read(inventoryNotifierProvider.notifier)
                          .addNewProduct(
                            title: 'Thermal Scanner Pro',
                            price: 49.99,
                            stockCount: 12,
                            description: 'Bluetooth handheld scanner',
                          );
                    },
                  ),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return ListTile(
                      title: Text(item.title),
                      subtitle: Text(
                        'Stock: ${item.stockCount} | \$${item.price.toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          ref
                              .read(inventoryNotifierProvider.notifier)
                              .updateStock(item.id, item.stockCount - 1);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _QrPreviewTab extends StatelessWidget {
  const _QrPreviewTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DeliveryQrView(orderId: 'ORD-90210', deliveryToken: 'QS-849201'),
    );
  }
}

class _ScannerPreviewTab extends StatelessWidget {
  const _ScannerPreviewTab();

  @override
  Widget build(BuildContext context) {
    return const DeliveryScannerView(orderId: '');
  }
}
