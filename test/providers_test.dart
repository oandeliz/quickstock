import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickstock/core/database/app_database.dart';
import 'package:quickstock/core/providers/database_provider.dart';
import 'package:quickstock/features/delivery/presentation/providers/delivery_notifier.dart';
import 'package:quickstock/features/orders/presentation/providers/order_notifier.dart';

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

  test('Test 1: createOrder creates an order with a delivery token', () async {
    final orderNotifier = container.read(orderNotifierProvider.notifier);
    final orderId = await orderNotifier.createOrder(
      customerId: 'user_123',
      totalAmount: 150.0,
    );

    final order = await (db.select(db.ordersTable)..where((t) => t.id.equals(orderId))).getSingle();
    
    expect(order.status, 'PENDING');
    expect(order.deliveryToken, isNotNull);
    // Token format is QS-XXXXXX (9 chars total) where XXXXXX are 6 random digits
    expect(order.deliveryToken.length, 9);
    expect(order.deliveryToken.startsWith('QS-'), true);
  });

  test('Test 2: verifyAndDeliver with correct token succeeds and incorrect token sets an error state', () async {
    final orderNotifier = container.read(orderNotifierProvider.notifier);
    final deliveryNotifier = container.read(deliveryNotifierProvider.notifier);
    
    final orderId = await orderNotifier.createOrder(
      customerId: 'user_123',
      totalAmount: 150.0,
    );
    final order = await (db.select(db.ordersTable)..where((t) => t.id.equals(orderId))).getSingle();

    // Verify incorrect token fails and sets error state
    final failSuccess = await deliveryNotifier.verifyAndDeliver(
      orderId: orderId,
      scannedToken: 'WRONG-TOKEN',
    );
    expect(failSuccess, false);
    
    final errorState = container.read(deliveryNotifierProvider);
    expect(errorState is AsyncError, true);
    
    // Verify correct token succeeds and clears error state (returns to AsyncData)
    final passSuccess = await deliveryNotifier.verifyAndDeliver(
      orderId: orderId,
      scannedToken: order.deliveryToken,
    );
    expect(passSuccess, true);
    
    final successState = container.read(deliveryNotifierProvider);
    expect(successState is AsyncData, true);
  });
}

