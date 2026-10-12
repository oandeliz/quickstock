import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickstock/core/database/app_database.dart';
import 'package:quickstock/core/providers/database_provider.dart';
import 'package:quickstock/features/delivery/presentation/providers/delivery_notifier.dart';
import 'package:quickstock/features/inventory/presentation/providers/inventory_notifier.dart';
import 'package:quickstock/features/orders/presentation/providers/order_notifier.dart';
import 'package:quickstock/core/database/tables/orders_table.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('Test 1: Call inventoryNotifierProvider.notifier.addNewProduct(...) and verify filteredProductsProvider reflects the new item', () async {
    // Start listening to the provider so it initializes
    final subscription = container.listen(filteredProductsProvider, (_, _) {});
    
    // Give stream time to initialize
    await Future.delayed(Duration.zero);

    final inventoryNotifier = container.read(inventoryNotifierProvider.notifier);
    
    await inventoryNotifier.addNewProduct(
      title: 'New Gadget',
      price: 19.99,
      stockCount: 10,
    );

    // Give stream time to emit new value
    await Future.delayed(const Duration(milliseconds: 100));

    final products = container.read(filteredProductsProvider);
    expect(products.length, 1);
    expect(products.first.title, 'New Gadget');
    
    subscription.close();
  });

  test('Test 2: Call productSearchQueryProvider.notifier.update(...) with a specific term and verify filteredProductsProvider filters the list correctly', () async {
    final subscription = container.listen(filteredProductsProvider, (_, _) {});
    final inventoryNotifier = container.read(inventoryNotifierProvider.notifier);
    
    await inventoryNotifier.addNewProduct(title: 'Apple', price: 1.0, stockCount: 10);
    await inventoryNotifier.addNewProduct(title: 'Banana', price: 1.0, stockCount: 10);

    // Give stream time to emit new values
    await Future.delayed(const Duration(milliseconds: 100));

    final searchQueryNotifier = container.read(productSearchQueryProvider.notifier);
    searchQueryNotifier.update('apple');

    final products = container.read(filteredProductsProvider);
    expect(products.length, 1);
    expect(products.first.title, 'Apple');

    subscription.close();
  });

  test('Test 3: Call orderNotifierProvider.notifier.createOrder(...) and verify an order is generated with a valid token', () async {
    final orderNotifier = container.read(orderNotifierProvider.notifier);
    final orderId = await orderNotifier.createOrder(
      customerId: 'user_123',
      totalAmount: 150.0,
    );

    final order = await (db.select(db.ordersTable)..where((t) => t.id.equals(orderId))).getSingle();
    
    expect(order.status, OrderStatus.pending);
    expect(order.deliveryToken, isNotNull);
    expect(order.deliveryToken.length, 9);
    expect(order.deliveryToken.startsWith('QS-'), true);
  });

  test('Test 4: Call deliveryNotifierProvider.notifier.verifyAndDeliver(...) with matching and mismatched tokens, checking return values and state', () async {
    final orderNotifier = container.read(orderNotifierProvider.notifier);
    final deliveryNotifier = container.read(deliveryNotifierProvider.notifier);
    
    final orderId = await orderNotifier.createOrder(
      customerId: 'user_123',
      totalAmount: 150.0,
    );
    final order = await (db.select(db.ordersTable)..where((t) => t.id.equals(orderId))).getSingle();

    final failSuccess = await deliveryNotifier.verifyAndDeliver(
      orderId: orderId,
      scannedToken: 'WRONG-TOKEN',
    );
    expect(failSuccess, false);
    
    final errorState = container.read(deliveryNotifierProvider);
    expect(errorState is AsyncError, true);
    
    final passSuccess = await deliveryNotifier.verifyAndDeliver(
      orderId: orderId,
      scannedToken: order.deliveryToken,
    );
    expect(passSuccess, true);
    
    final successState = container.read(deliveryNotifierProvider);
    expect(successState is AsyncData, true);
  });
}
