import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickstock/core/database/app_database.dart';
import 'package:quickstock/core/database/tables/orders_table.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Test 1: Insert a product into ProductsTable and assert it appears in watchAllProducts().first', () async {
    final product = ProductsTableCompanion.insert(
      id: 'prod-1',
      title: 'Test Product',
      stockCount: 10,
      price: 100.0,
    );
    
    await db.upsertProduct(product);
    
    final products = await db.watchAllProducts().first;
    expect(products.length, 1);
    expect(products.first.id, 'prod-1');
  });

  test('Test 2: Call confirmDelivery with matching token and assert order status updates to DELIVERED', () async {
    final order = OrdersTableCompanion.insert(
      id: 'ord-1',
      customerId: 'cust-1',
      status: OrderStatus.pending,
      deliveryToken: 'QS-123456',
      totalAmount: 50.0,
    );
    
    await db.into(db.ordersTable).insert(order);
    
    // confirmDelivery returns Future<void> so we await it. It completes successfully if token is valid.
    await db.confirmDelivery('ord-1', 'QS-123456');
    
    final updatedOrder = await (db.select(db.ordersTable)..where((t) => t.id.equals('ord-1'))).getSingle();
    expect(updatedOrder.status, OrderStatus.delivered);
  });

  test('Test 3: Call confirmDelivery with invalid token throws Exception and status remains PENDING', () async {
    final order = OrdersTableCompanion.insert(
      id: 'ord-2',
      customerId: 'cust-2',
      status: OrderStatus.pending,
      deliveryToken: 'QS-123456',
      totalAmount: 50.0,
    );
    
    await db.into(db.ordersTable).insert(order);
    
    // confirmDelivery throws Exception if token is invalid, so it does not return false directly.
    expect(() => db.confirmDelivery('ord-2', 'WRONG-TOKEN'), throwsException);
    
    final updatedOrder = await (db.select(db.ordersTable)..where((t) => t.id.equals('ord-2'))).getSingle();
    expect(updatedOrder.status, OrderStatus.pending);
  });
}
