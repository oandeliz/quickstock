import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickstock/core/auth/data/auth_repository.dart';
import 'package:quickstock/core/auth/domain/user_role.dart';

void main() {
  group('UserRole domain helpers', () {
    test('admin role permissions', () {
      const role = UserRole.admin;
      expect(role.isStaff, isTrue);
      expect(role.canManageInventory, isTrue);
      expect(role.isDriver, isFalse);
      expect(role.isCustomer, isFalse);
    });

    test('manager role permissions', () {
      const role = UserRole.manager;
      expect(role.isStaff, isTrue);
      expect(role.canManageInventory, isTrue);
      expect(role.isDriver, isFalse);
      expect(role.isCustomer, isFalse);
    });

    test('worker role permissions', () {
      const role = UserRole.worker;
      expect(role.isStaff, isTrue);
      expect(role.canManageInventory, isFalse);
      expect(role.isDriver, isFalse);
      expect(role.isCustomer, isFalse);
    });

    test('driver role permissions', () {
      const role = UserRole.driver;
      expect(role.isStaff, isTrue);
      expect(role.canManageInventory, isFalse);
      expect(role.isDriver, isTrue);
      expect(role.isCustomer, isFalse);
    });

    test('customer role permissions', () {
      const role = UserRole.customer;
      expect(role.isStaff, isFalse);
      expect(role.canManageInventory, isFalse);
      expect(role.isDriver, isFalse);
      expect(role.isCustomer, isTrue);
    });

    test('guest role permissions', () {
      const role = UserRole.guest;
      expect(role.isStaff, isFalse);
      expect(role.canManageInventory, isFalse);
      expect(role.isDriver, isFalse);
      expect(role.isCustomer, isTrue);
    });
  });

  group('AuthRepository and authStateProvider', () {
    test('unconfigured repository defaults to guest and null user', () async {
      const repo = AuthRepository();
      final role = await repo.getCurrentUserRole();
      final user = await repo.getCurrentUser();

      expect(role, equals(UserRole.guest));
      expect(user, isNull);
    });

    test('authStateProvider initializes to guest when unauthenticated', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final role = await container.read(authStateProvider.future);
      expect(role, equals(UserRole.guest));
    });
  });
}
