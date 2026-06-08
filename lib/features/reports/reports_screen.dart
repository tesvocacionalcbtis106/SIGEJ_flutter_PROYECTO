import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/original_widgets.dart';
import '../../data/firebase/firestore_database_adapter.dart';
import '../auth/auth_controller.dart';
import 'reports_controller.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _filterController = TextEditingController();
  String? _groupId;
  String? _loadedGroupId;

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = context.watch<FirestoreDatabaseAdapter>();
    final reports = context.watch<ReportsController>();
    final user = context.watch<AuthController>().currentUser;
    final groupIds = user?.groupIds.isEmpty == false ? user!.groupIds : ['1'];
    _groupId ??= groupIds.first;
    final groupName = database.groupName(_groupId!);

    if (_loadedGroupId != _groupId) {
      _loadedGroupId = _groupId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _groupId != null) {
          context.read<ReportsController>().loadByGroup(_groupId!);
        }
      });
    }

    final rows = reports.groupJustifications
        .where((item) => reports
            .studentName(item.studentId)
            .toLowerCase()
            .contains(_filterController.text.toLowerCase()))
        .toList();

    return Scaffold(
      body: Column(
        children: [
          OriginalHeader(
            roleText: '🧑‍🏫 MAESTRO',
            roleColor: AppColors.green,
            name: user?.fullName ?? 'Maestro',
          ),
          if (groupIds.length > 1)
            Container(
              color: AppColors.panel,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              child: Row(
                children: [
                  const Text('Ver grupo:', style: TextStyle(color: AppColors.mutedText)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _groupId,
                    dropdownColor: AppColors.card2,
                    items: groupIds
                        .map(
                          (id) => DropdownMenuItem(
                            value: id,
                            child: Text(database.groupName(id)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _groupId = value);
                    },
                  ),
                ],
              ),
            ),
          Container(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 11, 20, 11),
            child: Row(
              children: [
                Text(
                  'Justificantes — Grupo $groupName',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                const Text('🔍 ', style: TextStyle(color: AppColors.mutedText)),
                SizedBox(
                  width: 220,
                  height: 36,
                  child: TextField(
                    controller: _filterController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: OriginalTable(
                columns: const [
                  '#',
                  'Alumno',
                  'Periodo',
                  'Horario',
                  'Motivo',
                  'Registrado por',
                ],
                flexes: const [1, 5, 4, 3, 4, 4],
                rows: [
                  for (var i = 0; i < rows.length; i++)
                    [
                      '${i + 1}',
                      reports.studentName(rows[i].studentId),
                      rows[i].startDate == rows[i].endDate
                          ? rows[i].startDate
                          : '${rows[i].startDate}  →  ${rows[i].endDate}',
                      rows[i].allDay
                          ? 'Todo el dia'
                          : '${rows[i].startTime} – ${rows[i].endTime}',
                      rows[i].reason ?? '-',
                      rows[i].createdBy,
                    ],
                ],
              ),
            ),
          ),
          Container(
            height: 42,
            color: AppColors.panel,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Total: ${rows.length} justificantes   |   '
                  'Alumnos afectados: ${rows.map((item) => item.studentId).toSet().length}   |   '
                  'Grupo: $groupName',
                  style: const TextStyle(color: AppColors.mutedText),
                ),
                const Spacer(),
                FlatTextButton(
                  label: '↻ Actualizar',
                  background: AppColors.panel,
                  foreground: AppColors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  onPressed: () => setState(() {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
