import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/original_widgets.dart';
import '../../data/firebase/firestore_database_adapter.dart';
import '../auth/auth_controller.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  String _groupId = '1';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
final database = context.watch<FirestoreDatabaseAdapter>();
    final user = context.watch<AuthController>().currentUser;
    final group = database.groups.firstWhere((item) => item.id == _groupId);
    final students = database
        .studentsByGroup(_groupId)
        .where((student) =>
            student.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      body: Column(
        children: [
          OriginalHeader(
            roleText: '⬛ ADMIN',
            roleColor: AppColors.accent,
            name: user?.fullName ?? 'Administrador',
            backLabel: '← Grupos',
            onBack: () => context.go(AppRoutes.dashboard),
          ),
          Container(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                Text(
                  'Grupo  ${group.name}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 18),
                DropdownButton<String>(
                  value: _groupId,
                  dropdownColor: AppColors.card2,
                  items: database.groups
                      .map(
                        (group) => DropdownMenuItem(
                          value: group.id,
                          child: Text(group.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _groupId = value);
                  },
                ),
                const Spacer(),
                Container(
                  width: 245,
                  height: 36,
                  color: AppColors.card2,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Text('🔍', style: TextStyle(color: AppColors.mutedText)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: OriginalTable(
                columns: const ['#', 'Nombre del Alumno', 'Justificantes'],
                flexes: const [1, 8, 2],
                rows: [
                  for (var i = 0; i < students.length; i++)
                    [
                      '${i + 1}',
                      students[i].name,
                      '${database.justificationsByStudent(students[i].id).length}',
                    ],
                ],
                onRowTap: (index) => context.go(
                  '${AppRoutes.userForm}?studentId=${students[index].id}',
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              'Doble clic o Enter para seleccionar un alumno',
              style: TextStyle(color: AppColors.mutedText, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
