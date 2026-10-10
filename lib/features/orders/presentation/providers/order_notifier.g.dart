// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$completedOrdersHash() => r'5aece13cacd3cd83d8aad5c6e70a04d08a0c3080';

/// See also [completedOrders].
@ProviderFor(completedOrders)
final completedOrdersProvider =
    AutoDisposeStreamProvider<List<OrdersTableData>>.internal(
      completedOrders,
      name: r'completedOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$completedOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompletedOrdersRef =
    AutoDisposeStreamProviderRef<List<OrdersTableData>>;
String _$orderNotifierHash() => r'f8669528c1c2a6fa09e66273f5b7727c13f76681';

/// See also [OrderNotifier].
@ProviderFor(OrderNotifier)
final orderNotifierProvider =
    AutoDisposeStreamNotifierProvider<
      OrderNotifier,
      List<OrdersTableData>
    >.internal(
      OrderNotifier.new,
      name: r'orderNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$orderNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderNotifier = AutoDisposeStreamNotifier<List<OrdersTableData>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
