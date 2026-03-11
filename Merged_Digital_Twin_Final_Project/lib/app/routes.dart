import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/state.dart';
import '../screens/machines_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/history_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/profile_screen.dart';
import '../theme/dt_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    Widget screen;
    switch (app.currentTab) {
      case AppTab.machines:
        screen = const MachineListScreen();
        break;
      case AppTab.dashboard:
        screen = DashboardScreen(machineId: app.selectedMachineId);
        break;
      case AppTab.alerts:
        screen = const AlertsScreen();
        break;
      case AppTab.history:
        screen = const HistoryScreen();
        break;
      case AppTab.reports:
        screen = const ReportsScreen();
        break;
      case AppTab.profile:
        screen = const ProfileScreen();
        break;
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: screen),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomNav(),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    final items = const [
      _NavItem(AppTab.machines, Icons.grid_view_rounded, 'Machines'),
      _NavItem(AppTab.alerts, Icons.notifications_rounded, 'Alerts'),
      _NavItem(AppTab.history, Icons.access_time_rounded, 'History'),
      _NavItem(AppTab.reports, Icons.description_rounded, 'Reports'),
      _NavItem(AppTab.profile, Icons.person_rounded, 'Profile'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).alphaF(0.92),
          border: Border(top: BorderSide(color: DT.border(0.45))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((it) {
            final active = app.currentTab == it.tab;

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => context.read<AppState>().setTab(it.tab),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(it.icon, color: active ? DT.blue : DT.dim(0.55), size: 24),
                    const SizedBox(height: 3),
                    Text(
                      it.label,
                      style: TextStyle(
                        color: active ? DT.blue : DT.dim(0.55),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final AppTab tab;
  final IconData icon;
  final String label;
  const _NavItem(this.tab, this.icon, this.label);
}