// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inventoryRepositoryHash() =>
    r'f1bc58fc7910f1ff1540efa97280d4d7480ef3e6';

/// See also [inventoryRepository].
@ProviderFor(inventoryRepository)
final inventoryRepositoryProvider =
    AutoDisposeProvider<InventoryRepository>.internal(
      inventoryRepository,
      name: r'inventoryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inventoryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InventoryRepositoryRef = AutoDisposeProviderRef<InventoryRepository>;
String _$filteredProductsHash() => r'7e2a2fb64bf9de92066e31ec246b2a4a339a5938';

/// See also [filteredProducts].
@ProviderFor(filteredProducts)
final filteredProductsProvider =
    AutoDisposeProvider<List<ProductsTableData>>.internal(
      filteredProducts,
      name: r'filteredProductsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredProductsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredProductsRef = AutoDisposeProviderRef<List<ProductsTableData>>;
String _$lowStockProductsHash() => r'801dc58a53525b0052d7839f9ebcf662e7914cf9';

/// See also [lowStockProducts].
@ProviderFor(lowStockProducts)
final lowStockProductsProvider =
    AutoDisposeProvider<List<ProductsTableData>>.internal(
      lowStockProducts,
      name: r'lowStockProductsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lowStockProductsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LowStockProductsRef = AutoDisposeProviderRef<List<ProductsTableData>>;
String _$inventoryNotifierHash() => r'e07e3afbbad68c2c6d65540f762439c4253e6857';

/// See also [InventoryNotifier].
@ProviderFor(InventoryNotifier)
final inventoryNotifierProvider =
    AutoDisposeStreamNotifierProvider<
      InventoryNotifier,
      List<ProductsTableData>
    >.internal(
      InventoryNotifier.new,
      name: r'inventoryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inventoryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InventoryNotifier =
    AutoDisposeStreamNotifier<List<ProductsTableData>>;
String _$productSearchQueryHash() =>
    r'93d9af36560d846f0053a881a4a8c05edb0f0f7d';

/// See also [ProductSearchQuery].
@ProviderFor(ProductSearchQuery)
final productSearchQueryProvider =
    AutoDisposeNotifierProvider<ProductSearchQuery, String>.internal(
      ProductSearchQuery.new,
      name: r'productSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProductSearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
