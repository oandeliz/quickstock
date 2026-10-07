import 'package:drift/drift.dart';

enum OrderStatus {
  pending,
  outForDelivery,
  delivered,
}

class OrdersTable extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text()();
  // status: 'PENDING', 'OUT_FOR_DELIVERY', 'DELIVERED'
  TextColumn get status => text().map(const EnumNameConverter(OrderStatus.values))();
  TextColumn get deliveryToken => text()();
  RealColumn get totalAmount => real()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
