import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/original_widgets.dart';
import '../../data/firebase/firestore_database_adapter.dart';
import '../auth/auth_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
final database = context.watch<FirestoreDatabaseAdapter>();
    final user = context.watch<AuthController>().currentUser;
    final colors = [
      AppColors.accent,
      AppColors.purple,
      AppColors.teal,
      AppColors.green,
      AppColors.amber,
      AppColors.red,
      AppColors.accent2,
      AppColors.teal,
    ];
    final icons = ['📚', '📖', '📝', '✏️', '🎓', '📒', '🗒️', '📓'];

    return Scaffold(
      body: Column(
        children: [
          OriginalHeader(
            roleText: '⬛ ADMIN',
            roleColor: AppColors.accent,
            name: user?.fullName ?? 'Administrador',
          ),
          Container(height: 1, color: AppColors.border),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  const Text(
                    'Selecciona un Grupo',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '¿A que grupo deseas agregar un justificante?',
                    style: TextStyle(color: AppColors.mutedText, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 22,
                            crossAxisSpacing: 22,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: database.groups.length,
                          itemBuilder: (context, index) {
                            final group = database.groups[index];
                            final color = colors[index % colors.length];
                            return _GroupCard(
                              name: group.name,
                              icon: icons[index % icons.length],
                              color: color,
                              count: database.studentsByGroup(group.id).length,
                              onTap: () => context.go(AppRoutes.users),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatefulWidget {
  const _GroupCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  final String name;
  final String icon;
  final Color color;
  final int count;
  final VoidCallback onTap;

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          color: _hovered ? AppColors.card2 : AppColors.card,
          child: Column(
            children: [
              Container(height: 4, color: widget.color),
              const SizedBox(height: 12),
              Text(widget.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 4),
              Text(
                widget.name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${widget.count} alumnos',
                style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
