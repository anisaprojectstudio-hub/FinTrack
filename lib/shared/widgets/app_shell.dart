import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/transaction/presentation/pages/transaction_list_page.dart';

/// Bottom navigation utama FinTrack (sesuai struktur navigasi Tahap 4).
/// Tab Budget & Profile akan ditambahkan begitu fiturnya selesai dibuat —
/// untuk sekarang baru Dashboard & Transaksi yang punya fitur nyata.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [
    DashboardPage(),
    TransactionListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), label: 'Transaksi'),
        ],
      ),
    );
  }
}
