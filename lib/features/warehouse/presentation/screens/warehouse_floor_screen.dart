import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickstock/core/database/app_database.dart';
import 'package:quickstock/features/inventory/presentation/providers/inventory_notifier.dart';
import 'package:quickstock/features/orders/presentation/providers/order_notifier.dart';

class WarehouseFloorScreen extends ConsumerStatefulWidget {
  const WarehouseFloorScreen({super.key});

  @override
  ConsumerState<WarehouseFloorScreen> createState() => _WarehouseFloorScreenState();
}

class _WarehouseFloorScreenState extends ConsumerState<WarehouseFloorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showOverrideModal(BuildContext context, ProductsTableData product) {
    final TextEditingController countController = TextEditingController(text: product.stockCount.toString());
    String selectedReason = 'Received shipment';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Manual Stock Override', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Item: ${product.title}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: countController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'New Stock Count',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    decoration: const InputDecoration(
                      labelText: 'Override Reason',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Received shipment', child: Text('Received shipment')),
                      DropdownMenuItem(value: 'Damaged goods', child: Text('Damaged goods')),
                      DropdownMenuItem(value: 'Audit correction', child: Text('Audit correction')),
                    ],
                    onChanged: (val) {
                      if (val != null) setStateModal(() => selectedReason = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      final newCount = int.tryParse(countController.text) ?? product.stockCount;
                      ref.read(inventoryNotifierProvider.notifier).updateStock(product.id, newCount);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Stock updated. Reason: $selectedReason')),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Confirm Override'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Warehouse Operations', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Quick Scan Barcode',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Barcode scanner opening...')));
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade400,
          indicatorColor: Colors.amber,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Active Inventory'),
            Tab(text: 'Restock Approvals'),
            Tab(text: 'Outbound Packing'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveInventory(theme),
          _buildRestockApprovals(theme),
          _buildOutboundPacking(theme),
        ],
      ),
    );
  }

  Widget _buildActiveInventory(ThemeData theme) {
    final filtered = ref.watch(filteredProductsProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: SearchBar(
            hintText: 'Scan or search SKU, barcode, title...',
            leading: const Icon(Icons.search),
            trailing: [
              IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
            ],
            elevation: WidgetStateProperty.all(1),
            onChanged: (val) {
              ref.read(productSearchQueryProvider.notifier).update(val);
            },
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No inventory found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isLowStock = item.stockCount < 5;
                    
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.inventory_2, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'SKU: ${item.id.substring(0, 8).toUpperCase()}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'monospace'),
                                  ),
                                  if (isLowStock)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'LOW STOCK',
                                        style: TextStyle(color: theme.colorScheme.error, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    color: theme.colorScheme.onPrimaryContainer,
                                    onPressed: () {
                                      if (item.stockCount > 0) {
                                        HapticFeedback.lightImpact();
                                        ref.read(inventoryNotifierProvider.notifier).updateStock(item.id, item.stockCount - 1);
                                      }
                                    },
                                  ),
                                  Container(
                                    constraints: const BoxConstraints(minWidth: 40),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${item.stockCount}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    color: theme.colorScheme.onPrimaryContainer,
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      ref.read(inventoryNotifierProvider.notifier).updateStock(item.id, item.stockCount + 1);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.edit_note),
                              tooltip: 'Manual Override',
                              onPressed: () => _showOverrideModal(context, item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRestockApprovals(ThemeData theme) {
    final lowStock = ref.watch(lowStockProductsProvider);

    if (lowStock.isEmpty) {
      return const Center(child: Text('All stocks are healthy. No pending approvals.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: lowStock.length,
      itemBuilder: (context, index) {
        final item = lowStock[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Current Stock: ${item.stockCount}'),
            trailing: FilledButton.tonal(
              onPressed: () {
                ref.read(inventoryNotifierProvider.notifier).updateStock(item.id, item.stockCount + 50);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Approved 50 units.')));
              },
              child: const Text('Approve +50'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutboundPacking(ThemeData theme) {
    final pendingOrdersAsync = ref.watch(orderNotifierProvider);

    return pendingOrdersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(child: Text('No outbound orders pending packing.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.inventory, color: Colors.white)),
                title: Text('Order #${order.id.split('_').last}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Status: Ready to Pack'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening packing slip...')));
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
