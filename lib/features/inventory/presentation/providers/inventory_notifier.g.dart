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
String _$inventoryNotifierHash() => r'1363857f8c3e1cc2df7be467641a4fe2a4cbeb4c';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
