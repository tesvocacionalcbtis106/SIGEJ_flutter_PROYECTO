import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/original_widgets.dart';
import '../../data/firebase/firestore_database_adapter.dart';
import '../auth/auth_controller.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key, this.studentId});

  final String? studentId;

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  var _allDay = true;
  var _reason = 'Selecciona o escribe el motivo...';
  final _detailController = TextEditingController();

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
final database = context.watch<FirestoreDatabaseAdapter>();
    final user = context.watch<AuthController>().currentUser;
    final student = database.students.firstWhere(
      (item) => item.id == widget.studentId,
      orElse: () => database.students.first,
    );
    final group = database.groupName(student.groupId);
    final previous = database.justificationsByStudent(student.id);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      body: Column(
        children: [
          OriginalHeader(
            roleText: '⬛ ADMIN',
            roleColor: AppColors.accent,
            name: user?.fullName ?? 'Administrador',
            backLabel: '← Alumnos',
            onBack: () => context.go(AppRoutes.users),
          ),
          Container(height: 1, color: AppColors.border),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(50, 14, 50, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopStripeCard(
                      color: AppColors.amber,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ALUMNO SELECCIONADO',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            student.name,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Grupo: $group',
                            style: const TextStyle(color: AppColors.mutedText),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const AccentSectionLabel('📅  RANGO DE FECHAS'),
                    const Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _SmallDateBox(label: 'Desde:', value: '5 Junio 2026'),
                        _SmallDateBox(label: 'Hasta:', value: '5 Junio 2026'),
                      ],
                    ),
                    const AccentSectionLabel('⏰  HORARIO'),
                    Container(
                      color: AppColors.card,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _RadioRow(
                            selected: _allDay,
                            label: 'Todo el dia',
                            onTap: () => setState(() => _allDay = true),
                          ),
                          _RadioRow(
                            selected: !_allDay,
                            label: 'Rango de horas especifico',
                            onTap: () => setState(() => _allDay = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Desde:', style: TextStyle(color: AppColors.mutedText)),
                        const SizedBox(width: 6),
                        _TimeBox(value: '07:00', enabled: !_allDay),
                        const SizedBox(width: 18),
                        const Text('Hasta:', style: TextStyle(color: AppColors.mutedText)),
                        const SizedBox(width: 6),
                        _TimeBox(value: '14:00', enabled: !_allDay),
                      ],
                    ),
                    const AccentSectionLabel('📝  MOTIVO  (opcional)'),
                    SizedBox(
                      width: 360,
                      child: DropdownButtonFormField<String>(
                        initialValue: _reason,
                        dropdownColor: AppColors.card2,
                        items: const [
                          'Selecciona o escribe el motivo...',
                          'Cita medica',
                          'Enfermedad',
                          'Asunto familiar urgente',
                          'Tramite oficial',
                          'Evento deportivo/cultural',
                          'Otro',
                        ]
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _reason = value!),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 82,
                      child: TextField(
                        controller: _detailController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Escribe el motivo...',
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        FlatTextButton(
                          label: 'Cancelar',
                          background: AppColors.card,
                          foreground: AppColors.mutedText,
                          onPressed: () => context.go(AppRoutes.users),
                        ),
                        const SizedBox(width: 10),
                        FlatTextButton(
                          label: '✔  Guardar Justificante',
                          background: AppColors.green,
                          onPressed: () {
                            final typedReason = _detailController.text.trim();
                            final selectedReason = _reason.startsWith('Selecciona')
                                ? ''
                                : _reason;
                            database.addJustification(
                              studentId: student.id,
                              startDate: today,
                              endDate: today,
                              allDay: _allDay,
                              startTime: '07:00',
                              endTime: '14:00',
                              reason: typedReason.isNotEmpty
                                  ? typedReason
                                  : selectedReason,
                              createdBy: user?.fullName ?? 'Administrador',
                            );
                            context.go(AppRoutes.users);
                          },
                        ),
                      ],
                    ),
                    if (previous.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Container(height: 1, color: AppColors.border),
                      const SizedBox(height: 10),
                      Text(
                        'Justificantes previos (${previous.length})',
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 170,
                        child: OriginalTable(
                          columns: const [
                            'Periodo',
                            'Horario',
                            'Motivo',
                            'Registrado por',
                          ],
                          flexes: const [3, 2, 4, 3],
                          rows: [
                            for (final item in previous)
                              [
                                item.startDate == item.endDate
                                    ? item.startDate
                                    : '${item.startDate}  →  ${item.endDate}',
                                item.allDay
                                    ? 'Todo el dia'
                                    : '${item.startTime} – ${item.endTime}',
                                item.reason ?? '-',
                                item.createdBy,
                              ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallDateBox extends StatelessWidget {
  const _SmallDateBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: AppColors.mutedText)),
        const SizedBox(width: 6),
        Container(
          color: AppColors.card2,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(value),
        ),
      ],
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.accent : AppColors.mutedText,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.white)),
          ],
        ),
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.value, required this.enabled});

  final String value;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: Container(
        color: AppColors.card2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(value),
      ),
    );
  }
}
