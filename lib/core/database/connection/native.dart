import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor connect() {
  return driftDatabase(
    name: 'quickstock_db',
  );
}
