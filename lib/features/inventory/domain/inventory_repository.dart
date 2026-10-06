import 'package:quickstock/core/database/app_database.dart';

abstract class InventoryRepository {
  Stream<List<ProductsTableData>> watchProducts();
  Future<void> syncProductsFromCloud();
  Future<void> updateStock(String productId, int newCount);
}
