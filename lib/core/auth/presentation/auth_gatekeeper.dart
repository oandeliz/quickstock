import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickstock/core/auth/data/auth_repository.dart';
import 'package:quickstock/core/auth/domain/user_role.dart';
import 'package:quickstock/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:quickstock/features/customer/presentation/screens/customer_storefront_screen.dart';
import 'package:quickstock/features/delivery/presentation/screens/driver_dashboard_screen.dart';
import 'package:quickstock/features/navigation/presentation/screens/dev_role_shell.dart';
import 'package:quickstock/features/warehouse/presentation/screens/warehouse_floor_screen.dart';

/// Reactive root gatekeeper that observes [authStateProvider] and renders
/// the appropriate dashboard screen based on resolved [UserRole].
class AuthGatekeeper extends ConsumerStatefulWidget {
  const AuthGatekeeper({super.key});

  @override
  ConsumerState<AuthGatekeeper> createState() => _AuthGatekeeperState();
}

class _AuthGatekeeperState extends ConsumerState<AuthGatekeeper> {
  bool _useDevShell = false;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode && _useDevShell) {
      return Stack(
        children: [
          const DevRoleShell(),
          Positioned(
            top: 48,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(20),
              color: Colors.amber.shade800,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _useDevShell = false),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Exit Dev Shell',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'QuickStock',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Resolving user authentication session...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 56,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Authentication Error',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => ref.refresh(authStateProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Session'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (role) {
        final Widget targetScreen = switch (role) {
          UserRole.guest ||
          UserRole.customer =>
            const CustomerStorefrontScreen(),
          UserRole.driver => const DriverDashboardScreen(),
          UserRole.worker => const WarehouseFloorScreen(),
          UserRole.admin ||
          UserRole.manager =>
            const AdminDashboardScreen(),
        };

        if (!kDebugMode) {
          return targetScreen;
        }

        return Stack(
          children: [
            targetScreen,
            Positioned(
              bottom: 24,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(24),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => setState(() => _useDevShell = true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.developer_mode,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Dev Shell (${role.name})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
