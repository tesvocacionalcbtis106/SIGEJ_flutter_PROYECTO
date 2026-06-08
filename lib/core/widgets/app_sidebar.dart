import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../constants/app_texts.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return NavigationRail(
      selectedIndex: _indexFor(location),
      onDestinationSelected: (index) => context.go(_routeFor(index)),
      labelType: NavigationRailLabelType.all,
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Text(
          AppTexts.appName,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text(AppTexts.dashboard),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_alt_outlined),
          selectedIcon: Icon(Icons.people_alt),
          label: Text(AppTexts.users),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: Text(AppTexts.admin),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.insert_chart_outlined),
          selectedIcon: Icon(Icons.insert_chart),
          label: Text(AppTexts.reports),
        ),
      ],
    );
  }

  int _indexFor(String location) {
    if (location.startsWith(AppRoutes.users)) return 1;
    if (location.startsWith(AppRoutes.admin)) return 2;
    if (location.startsWith(AppRoutes.reports)) return 3;
    return 0;
  }

  String _routeFor(int index) {
    return switch (index) {
      1 => AppRoutes.users,
      2 => AppRoutes.admin,
      3 => AppRoutes.reports,
      _ => AppRoutes.dashboard,
    };
  }
}
