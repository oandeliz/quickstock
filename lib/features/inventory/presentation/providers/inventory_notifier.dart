import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:quickstock/core/database/app_database.dart';
import 'package:quickstock/core/providers/database_provider.dart';
import 'package:quickstock/features/inventory/data/inventory_repository_impl.dart';
import 'package:quickstock/features/inventory/domain/inventory_repository.dart';

part 'inventory_notifier.g.dart';

@riverpod
InventoryRepository inventoryRepository(InventoryRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return InventoryRepositoryImpl(db);
}

@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  @override
  Stream<List<ProductsTableData>> build() {
    final db = ref.watch(appDatabaseProvider);
    return db.watchAllProducts();
  }

  Future<void> updateStock(String productId, int newCount) async {
    final repository = ref.read(inventoryRepositoryProvider);
    await repository.updateStock(productId, newCount);
  }

  Future<void> syncFromCloud() async {
    final repository = ref.read(inventoryRepositoryProvider);
    await repository.syncProductsFromCloud();
  }
}
