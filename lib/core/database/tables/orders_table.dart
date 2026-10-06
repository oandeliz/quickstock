import 'package:drift/drift.dart';

class OrdersTable extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text()();
  TextColumn get status => text()(); // values: 'PENDING', 'OUT_FOR_DELIVERY', 'DELIVERED'
  TextColumn get deliveryToken => text()();
  RealColumn get totalAmount => real()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
