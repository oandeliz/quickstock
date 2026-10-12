import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/presentation/auth_gatekeeper.dart';

void main() {
  runApp(const ProviderScope(child: QuickStockPreviewApp()));
}

class QuickStockPreviewApp extends StatelessWidget {
  const QuickStockPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickStock Preview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGatekeeper(),
    );
  }
}
