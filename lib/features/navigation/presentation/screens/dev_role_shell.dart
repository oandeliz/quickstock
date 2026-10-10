import 'package:flutter/material.dart';
import 'package:quickstock/features/customer/presentation/screens/customer_storefront_screen.dart';
import 'package:quickstock/features/delivery/presentation/screens/driver_dashboard_screen.dart';
import 'package:quickstock/features/warehouse/presentation/screens/warehouse_floor_screen.dart';
import 'package:quickstock/features/admin/presentation/screens/admin_dashboard_screen.dart';

class DevRoleShell extends StatefulWidget {
  const DevRoleShell({super.key});

  @override
  State<DevRoleShell> createState() => _DevRoleShellState();
}

class _DevRoleShellState extends State<DevRoleShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CustomerStorefrontScreen(),
    DriverDashboardScreen(),
    WarehouseFloorScreen(),
    AdminDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Customer',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'Driver',
          ),
          NavigationDestination(
            icon: Icon(Icons.warehouse_outlined),
            selectedIcon: Icon(Icons.warehouse),
            label: 'Warehouse',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
