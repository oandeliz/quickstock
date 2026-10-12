import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
// ignore: deprecated_member_use
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';

DatabaseConnection connect() {
  return DatabaseConnection.delayed(Future.sync(() async {
    try {
      final db = await WasmDatabase.open(
        databaseName: 'quickstock_db',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
        initializeDatabase: () async => null,
      );
      return db.resolvedExecutor;
    } catch (e) {
      debugPrint(
        'WasmDatabase.open failed ($e). Falling back to WebDatabase / IndexedDB.',
      );
      try {
        final storage =
            await DriftWebStorage.indexedDbIfSupported('quickstock_db');
        return DatabaseConnection(WebDatabase.withStorage(storage));
      } catch (fallbackError) {
        debugPrint(
          'WebDatabase fallback failed ($fallbackError). Using in-memory WebDatabase.',
        );
        return DatabaseConnection(WebDatabase('quickstock_db'));
      }
    }
  }));
}
