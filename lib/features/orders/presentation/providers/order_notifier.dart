import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:quickstock/core/database/app_database.dart';
import 'package:quickstock/core/providers/database_provider.dart';
import 'package:quickstock/core/database/tables/orders_table.dart';

part 'order_notifier.g.dart';

@riverpod
class OrderNotifier extends _$OrderNotifier {
  @override
  Stream<List<OrdersTableData>> build() {
    final db = ref.watch(appDatabaseProvider);
    return db.watchPendingOrders();
  }

  Future<String> createOrder({required String customerId, required double totalAmount}) async {
    final db = ref.read(appDatabaseProvider);
    
    final secureRandom = Random.secure();
    final randomDigits = List.generate(6, (_) => secureRandom.nextInt(10)).join();
    final token = 'QS-$randomDigits';
    
    final orderId = 'ord_${DateTime.now().millisecondsSinceEpoch}_${secureRandom.nextInt(1000)}';

    await db.into(db.ordersTable).insert(
      OrdersTableCompanion.insert(

        id: orderId,
        customerId: customerId,
        status: OrderStatus.pending,
        deliveryToken: token,
        totalAmount: totalAmount,
      )
    );

    return orderId;
  }
}

@riverpod
Stream<List<OrdersTableData>> completedOrders(CompletedOrdersRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchCompletedOrders();
}
