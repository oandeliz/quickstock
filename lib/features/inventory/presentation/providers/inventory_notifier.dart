import 'package:drift/drift.dart';
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

  Future<void> addNewProduct({
    required String title,
    required double price,
    required int stockCount,
    String? description,
  }) async {
    final db = ref.read(appDatabaseProvider);
    await db.into(db.productsTable).insert(
          ProductsTableCompanion.insert(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            price: price,
            stockCount: stockCount,
            description: description != null ? Value(description) : const Value.absent(),
          ),
        );
  }
}

@riverpod
class ProductSearchQuery extends _$ProductSearchQuery {
  @override
  String build() => '';
  void update(String query) => state = query;
}

@riverpod
List<ProductsTableData> filteredProducts(FilteredProductsRef ref) {
  final query = ref.watch(productSearchQueryProvider).toLowerCase().trim();
  final inventory = ref.watch(inventoryNotifierProvider).value ?? [];
  if (query.isEmpty) return inventory;
  return inventory.where((p) => p.title.toLowerCase().contains(query)).toList();
}

@riverpod
List<ProductsTableData> lowStockProducts(LowStockProductsRef ref) {
  final inventory = ref.watch(inventoryNotifierProvider).value ?? [];
  return inventory.where((p) => p.stockCount < 5).toList();
}
