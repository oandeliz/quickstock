import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:quickstock/core/database/app_database.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}
