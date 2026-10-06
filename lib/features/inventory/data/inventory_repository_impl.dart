import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:drift/drift.dart';
import 'package:quickstock/core/database/app_database.dart';
import 'package:quickstock/features/inventory/domain/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final AppDatabase _db;

  InventoryRepositoryImpl(this._db);

  @override
  Stream<List<ProductsTableData>> watchProducts() {
    return _db.watchAllProducts();
  }

  @override
  Future<void> syncProductsFromCloud() async {
    try {
      const graphQLDocument = '''
        query ListProducts {
          listProducts {
            items {
              id
              title
              description
              price
              stockCount
            }
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(document: graphQLDocument);
      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null) {
        final Map<String, dynamic> data = jsonDecode(response.data!);
        final items = data['listProducts']?['items'] as List<dynamic>?;
        
        if (items != null) {
          for (final item in items) {
            final product = ProductsTableCompanion(
              id: Value(item['id'] as String),
              title: Value(item['title'] as String),
              description: Value(item['description'] as String?),
              price: Value((item['price'] as num).toDouble()),
              stockCount: Value(item['stockCount'] as int),
              isSynced: const Value(true),
            );
            await _db.upsertProduct(product);
          }
        }
      }
    } catch (e) {
      safePrint('Error syncing products: \$e');
    }
  }

  @override
  Future<void> updateStock(String productId, int newCount) async {
    try {
      final productData = await (_db.select(_db.productsTable)
            ..where((t) => t.id.equals(productId)))
          .getSingle();
          
      // Update Drift first with isSynced = false
      await _db.upsertProduct(
        productData.copyWith(
          stockCount: newCount,
          isSynced: false,
        ).toCompanion(false),
      );

      // Attempt an Amplify API mutation
      const mutationDocument = '''
        mutation UpdateProduct(\$id: ID!, \$stockCount: Int!) {
          updateProduct(input: {id: \$id, stockCount: \$stockCount}) {
            id
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(
        document: mutationDocument,
        variables: {
          'id': productId,
          'stockCount': newCount,
        },
      );
      
      await Amplify.API.mutate(request: request).response;

      // If successful, toggle isSynced = true
      await _db.upsertProduct(
        productData.copyWith(
          stockCount: newCount,
          isSynced: true,
        ).toCompanion(false),
      );
    } catch (e) {
      safePrint('Error updating stock on cloud: \$e');
    }
  }
}
