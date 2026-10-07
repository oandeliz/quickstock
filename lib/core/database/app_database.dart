import 'package:drift/drift.dart';

import 'connection/connection.dart';
import 'tables/products_table.dart';
import 'tables/orders_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [ProductsTable, OrdersTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connect());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  Stream<List<ProductsTableData>> watchAllProducts() {
    return select(productsTable).watch();
  }

  Future<void> upsertProduct(ProductsTableCompanion product) {
    return into(productsTable).insertOnConflictUpdate(product);
  }

  Future<void> decrementStock(String productId, int quantity) {
    return transaction(() async {
      final product = await (select(productsTable)
            ..where((t) => t.id.equals(productId)))
          .getSingle();
      if (product.stockCount >= quantity) {
        await update(productsTable).replace(
          product.copyWith(stockCount: product.stockCount - quantity),
        );
      } else {
        throw Exception('Insufficient stock');
      }
    });
  }

  Stream<List<OrdersTableData>> watchPendingOrders() {
    return (select(ordersTable)
          ..where((t) => t.status.isInValues([OrderStatus.pending, OrderStatus.outForDelivery])))
        .watch();
  }

  Future<void> confirmDelivery(String orderId, String token) {
    return transaction(() async {
      final order = await (select(ordersTable)
            ..where((t) => t.id.equals(orderId)))
          .getSingle();
      if (order.deliveryToken == token) {
        await update(ordersTable).replace(
          order.copyWith(status: OrderStatus.delivered),
        );
      } else {
        throw Exception('Invalid delivery token');
      }
    });
  }
}
