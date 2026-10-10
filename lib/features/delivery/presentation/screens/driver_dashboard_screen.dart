import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickstock/core/database/app_database.dart';
import 'package:quickstock/features/orders/presentation/providers/order_notifier.dart';
import 'package:quickstock/features/delivery/presentation/widgets/delivery_scanner_view.dart';

class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> with SingleTickerProviderStateMixin {
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

  void _openScanner(BuildContext context, String orderId) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: DeliveryScannerView(orderId: orderId),
        ),
      ),
    );

    if (result == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery successful! Moved to completed stops.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingOrdersAsync = ref.watch(orderNotifierProvider);
    final completedOrdersAsync = ref.watch(completedOrdersProvider);
    final theme = Theme.of(context);

    final pendingCount = pendingOrdersAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, size: 10, color: Colors.green),
                SizedBox(width: 6),
                Text('Online / On Route', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          tabs: [
            Tab(text: 'Active Stops ($pendingCount)'),
            const Tab(text: 'Completed Stops'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.amber.shade100,
            child: Row(
              children: [
                Icon(Icons.offline_bolt, color: Colors.amber.shade900, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Offline Mode Active: Scans are saved locally if you lose cellular connection.',
                    style: TextStyle(color: Colors.amber.shade900, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveStops(pendingOrdersAsync),
                _buildCompletedStops(completedOrdersAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStops(AsyncValue<List<OrdersTableData>> asyncOrders) {
    return asyncOrders.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(child: Text('No active deliveries. You\'re all caught up! 🎉'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.id.split('_').last}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(order.customerId == 'GUEST' ? 'Guest Customer' : order.customerId),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(child: Text('123 Delivery Route Ave, Logistics City, CA 90210')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _openScanner(context, order.id),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Verify Drop-off'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildCompletedStops(AsyncValue<List<OrdersTableData>> asyncOrders) {
    return asyncOrders.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(child: Text('No completed deliveries yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final order = orders[index];
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white),
              ),
              title: Text('Order #${order.id.split('_').last}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Delivered successfully'),
              trailing: Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
