import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:quickstock/core/providers/database_provider.dart';

part 'delivery_notifier.g.dart';

@riverpod
class DeliveryNotifier extends _$DeliveryNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> verifyAndDeliver({required String orderId, required String scannedToken}) async {
    state = const AsyncLoading();
    
    try {
      final db = ref.read(appDatabaseProvider);
      
      final order = await (db.select(db.ordersTable)
        ..where((t) => t.id.equals(orderId))).getSingle();
        
      if (order.deliveryToken == scannedToken.trim()) {
        await db.confirmDelivery(orderId, scannedToken);
        state = const AsyncData(null);
        return true;
      } else {
        state = AsyncError('Verification failed: Invalid token', StackTrace.current);
        return false;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
