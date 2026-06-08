import 'package:flutter/material.dart';

import '../../core/widgets/app_sidebar.dart';

class SuperAdminScreen extends StatelessWidget {
  const SuperAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          AppSidebar(),
          VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Super administrador',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
