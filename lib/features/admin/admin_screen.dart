import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/original_widgets.dart';
import '../../data/firebase/firestore_database_adapter.dart';
import '../../models/role_model.dart';
import '../../models/teacher_model.dart';
import '../auth/auth_controller.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _studentGroup = '1';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final database = context.watch<FirestoreDatabaseAdapter>();

    if (!database.groups.any((group) => group.id == _studentGroup) &&
        database.groups.isNotEmpty) {
      _studentGroup = database.groups.first.id;
    }

    return Scaffold(
      body: Column(
        children: [
          OriginalHeader(
            roleText: 'SUPER ADMIN',
            roleColor: AppColors.amber,
            name: user?.fullName ?? 'Super Administrador',
          ),
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  Container(
                    color: AppColors.panel,
                    child: const TabBar(
                      indicatorColor: AppColors.accent2,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.white,
                      unselectedLabelColor: AppColors.mutedText,
                      tabs: [
                        Tab(text: '  Grupos  '),
                        Tab(text: '  Alumnos  '),
                        Tab(text: '  Maestros  '),
                        Tab(text: '  Administradores  '),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        const _GroupsTab(),
                        _StudentsTab(
                          selectedGroup: _studentGroup,
                          onGroupChanged: (value) {
                            if (value != null) setState(() => _studentGroup = value);
                          },
                        ),
                        const _TeachersTab(),
                        const _AdminsTab(),
                      ],
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

class _AdminsTab extends StatefulWidget {
  const _AdminsTab();

  @override
  State<_AdminsTab> createState() => _AdminsTabState();
}

class _AdminsTabState extends State<_AdminsTab> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final database = context.watch<FirestoreDatabaseAdapter>();
    final admins =
        database.users.where((user) => user.role == UserRole.admin).toList();

    if (_selected >= admins.length) _selected = admins.length - 1;
    final admin = admins.isEmpty || _selected < 0 ? null : admins[_selected];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Administradores registrados',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 22),
              const Text('Seleccionar:', style: TextStyle(color: AppColors.mutedText)),
              const SizedBox(width: 6),
              DropdownButton<int>(
                value: admins.isEmpty ? null : _selected,
                dropdownColor: AppColors.card2,
                items: [
                  for (var i = 0; i < admins.length; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text('${admins[i].fullName} (${admins[i].username})'),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selected = value);
                },
              ),
              const Spacer(),
              FlatTextButton(
                label: '+ Nuevo administrador',
                background: AppColors.green,
                onPressed: () => _showAdminDialog(context, database),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: OriginalTable(
              columns: const ['Nombre', 'Usuario', 'Rol'],
              flexes: const [4, 2, 2],
              selectedIndex: _selected < 0 ? null : _selected,
              onRowTap: (index) => setState(() => _selected = index),
              rows: [
                for (final admin in admins)
                  [
                    admin.fullName,
                    admin.username,
                    admin.role.label,
                  ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              FlatTextButton(
                label: 'Cambiar contrasena',
                background: AppColors.teal,
                onPressed: admin == null
                    ? null
                    : () => _showTextDialog(
                          context: context,
                          title: 'Nueva contrasena',
                          label: 'Nueva contrasena:',
                          obscureText: true,
                          onSave: (value) =>
                              database.changeAdminPassword(admin.id, value),
                        ),
              ),
              const SizedBox(width: 8),
              FlatTextButton(
                label: 'Eliminar',
                background: AppColors.red,
                onPressed: admin == null
                    ? null
                    : () => _confirm(
                          context: context,
                          title: 'Eliminar administrador',
                          message:
                              "Eliminar al administrador '${admin.fullName}'?",
                          onConfirm: () => database.deleteAdmin(admin.id),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupsTab extends StatefulWidget {
  const _GroupsTab();

  @override
  State<_GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<_GroupsTab> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final database = context.watch<FirestoreDatabaseAdapter>();

    if (_selected >= database.groups.length) _selected = database.groups.length - 1;
    final selectedGroup =
        database.groups.isEmpty ? null : database.groups[_selected];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Grupos registrados',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 22),
              const Text('Seleccionar:', style: TextStyle(color: AppColors.mutedText)),
              const SizedBox(width: 6),
              DropdownButton<int>(
                value: database.groups.isEmpty ? null : _selected,
                dropdownColor: AppColors.card2,
                items: [
                  for (var i = 0; i < database.groups.length; i++)
                    DropdownMenuItem(value: i, child: Text(database.groups[i].name)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selected = value);
                },
              ),
              const Spacer(),
              FlatTextButton(
                label: '+ Nuevo grupo',
                background: AppColors.green,
                onPressed: () => _showTextDialog(
                  context: context,
                  title: 'Nuevo Grupo',
                  label: 'Nombre del grupo (ej: 3A):',
                  onSave: (value) => database.addGroup(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: OriginalTable(
              columns: const ['Nombre del Grupo', 'Alumnos'],
              flexes: const [5, 2],
              selectedIndex: _selected < 0 ? null : _selected,
              onRowTap: (index) => setState(() => _selected = index),
              rows: [
                for (final group in database.groups)
                  [
                    group.name,
                    '${database.studentsByGroup(group.id).length}',
                  ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              FlatTextButton(
                label: 'Eliminar grupo',
                background: AppColors.red,
                onPressed: selectedGroup == null
                    ? null
                    : () => _confirm(
                          context: context,
                          title: 'Eliminar grupo',
                          message:
                              "Eliminar '${selectedGroup.name}'? Tambien se eliminaran sus alumnos y justificantes.",
                          onConfirm: () => database.deleteGroup(selectedGroup.id),
                        ),
              ),
              const SizedBox(width: 8),
              FlatTextButton(
                label: 'Editar nombre',
                background: AppColors.amber,
                foreground: AppColors.background,
                onPressed: selectedGroup == null
                    ? null
                    : () => _showTextDialog(
                          context: context,
                          title: 'Editar Grupo',
                          label: 'Nuevo nombre del grupo:',
                          initialValue: selectedGroup.name,
                          onSave: (value) =>
                              database.editGroup(selectedGroup.id, value),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudentsTab extends StatefulWidget {
  const _StudentsTab({
    required this.selectedGroup,
    required this.onGroupChanged,
  });

  final String selectedGroup;
  final ValueChanged<String?> onGroupChanged;

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final database = context.watch<FirestoreDatabaseAdapter>();
    final students = database.studentsByGroup(widget.selectedGroup);

    if (_selected >= students.length) _selected = students.length - 1;
    final selectedStudent =
        students.isEmpty || _selected < 0 ? null : students[_selected];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Grupo:', style: TextStyle(color: AppColors.mutedText)),
              const SizedBox(width: 6),
              DropdownButton<String>(
                value: widget.selectedGroup,
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
                  setState(() => _selected = 0);
                  widget.onGroupChanged(value);
                },
              ),
              const Spacer(),
              FlatTextButton(
                label: '+ Agregar alumno',
                background: AppColors.green,
                onPressed: () => _showTextDialog(
                  context: context,
                  title: 'Nuevo Alumno',
                  label: 'Nombre (Apellido Paterno Materno, Nombre):',
                  onSave: (value) =>
                      database.addStudent(widget.selectedGroup, value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: OriginalTable(
              columns: const ['#', 'Nombre del Alumno'],
              flexes: const [1, 8],
              selectedIndex: _selected < 0 ? null : _selected,
              onRowTap: (index) => setState(() => _selected = index),
              rows: [
                for (var i = 0; i < students.length; i++)
                  ['${i + 1}', students[i].name]
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              FlatTextButton(
                label: 'Editar',
                background: AppColors.amber,
                foreground: AppColors.background,
                onPressed: selectedStudent == null
                    ? null
                    : () => _showTextDialog(
                          context: context,
                          title: 'Editar Alumno',
                          label: 'Nuevo nombre:',
                          initialValue: selectedStudent.name,
                          onSave: (value) =>
                              database.editStudent(selectedStudent.id, value),
                        ),
              ),
              const SizedBox(width: 8),
              FlatTextButton(
                label: 'Eliminar',
                background: AppColors.red,
                onPressed: selectedStudent == null
                    ? null
                    : () => _confirm(
                          context: context,
                          title: 'Eliminar alumno',
                          message: "Eliminar a '${selectedStudent.name}'?",
                          onConfirm: () =>
                              database.deleteStudent(selectedStudent.id),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeachersTab extends StatefulWidget {
  const _TeachersTab();

  @override
  State<_TeachersTab> createState() => _TeachersTabState();
}

class _TeachersTabState extends State<_TeachersTab> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final database = context.watch<FirestoreDatabaseAdapter>();

    if (_selected >= database.teachers.length) {
      _selected = database.teachers.length - 1;
    }

    final teacher = database.teachers.isEmpty || _selected < 0
        ? null
        : database.teachers[_selected];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Maestros registrados',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 22),
              const Text('Seleccionar:', style: TextStyle(color: AppColors.mutedText)),
              const SizedBox(width: 6),
              DropdownButton<int>(
                value: database.teachers.isEmpty ? null : _selected,
                dropdownColor: AppColors.card2,
                items: [
                  for (var i = 0; i < database.teachers.length; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(
                        '${database.teachers[i].name} (${database.teachers[i].username})',
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selected = value);
                },
              ),
              const Spacer(),
              FlatTextButton(
                label: '+ Nuevo maestro',
                background: AppColors.green,
                onPressed: () => _showTeacherDialog(context, database),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: OriginalTable(
              columns: const ['Nombre', 'Usuario', 'Grupos asignados'],
              flexes: const [4, 2, 4],
              selectedIndex: _selected < 0 ? null : _selected,
              onRowTap: (index) => setState(() => _selected = index),
              rows: [
                for (final teacher in database.teachers)
                  [
                    teacher.name,
                    teacher.username,
                    teacher.groupIds.map(database.groupName).join(', '),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              FlatTextButton(
                label: 'Editar grupos',
                background: AppColors.amber,
                foreground: AppColors.background,
                onPressed: teacher == null
                    ? null
                    : () => _showTeacherGroupsDialog(context, database, teacher),
              ),
              const SizedBox(width: 8),
              FlatTextButton(
                label: 'Cambiar contrasena',
                background: AppColors.teal,
                onPressed: teacher == null
                    ? null
                    : () => _showTextDialog(
                          context: context,
                          title: 'Nueva contrasena',
                          label: 'Nueva contrasena:',
                          obscureText: true,
                          onSave: (value) =>
                              database.changeTeacherPassword(teacher.id, value),
                        ),
              ),
              const SizedBox(width: 8),
              FlatTextButton(
                label: 'Eliminar',
                background: AppColors.red,
                onPressed: teacher == null
                    ? null
                    : () => _confirm(
                          context: context,
                          title: 'Eliminar maestro',
                          message: "Eliminar al maestro '${teacher.name}'?",
                          onConfirm: () => database.deleteTeacher(teacher.id),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _showTextDialog({
  required BuildContext context,
  required String title,
  required String label,
  required ValueChanged<String> onSave,
  String initialValue = '',
  bool obscureText = false,
}) async {
  final controller = TextEditingController(text: initialValue);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => _OriginalDialog(
      title: title,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (_) {
          onSave(controller.text);
          Navigator.pop(dialogContext);
        },
      ),
      onSave: () {
        onSave(controller.text);
        Navigator.pop(dialogContext);
      },
    ),
  );
}

Future<void> _showTeacherDialog(
  BuildContext context,
  FirestoreDatabaseAdapter database,
) async {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final selectedGroups = <String>{
    if (database.groups.isNotEmpty) database.groups.first.id
  };

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => _OriginalDialog(
        title: 'Nuevo Maestro',
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre completo:'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Usuario (login):'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo Firebase:'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contrasena:'),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Grupos asignados:',
                style: TextStyle(color: AppColors.mutedText),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final group in database.groups)
                  FilterChip(
                    selected: selectedGroups.contains(group.id),
                    label: Text(group.name),
                    selectedColor: AppColors.accent,
                    backgroundColor: AppColors.card2,
                    onSelected: (selected) {
                      setDialogState(() {
                        if (selected) {
                          selectedGroups.add(group.id);
                        } else if (selectedGroups.length > 1) {
                          selectedGroups.remove(group.id);
                        }
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
        onSave: () {
          database.addTeacher(
            name: nameController.text,
            username: usernameController.text,
            email: emailController.text,
            password: passwordController.text,
            groupIds: selectedGroups.toList(),
          );
          Navigator.pop(dialogContext);
        },
      ),
    ),
  );
}

Future<void> _showAdminDialog(
  BuildContext context,
  FirestoreDatabaseAdapter database,
) async {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => _OriginalDialog(
      title: 'Nuevo Administrador',
      width: 440,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nombre completo:'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(labelText: 'Usuario (login):'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Correo Firebase:'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contrasena:'),
          ),
        ],
      ),
      onSave: () {
        database.addAdmin(
          name: nameController.text,
          username: usernameController.text,
          email: emailController.text,
          password: passwordController.text,
        );
        Navigator.pop(dialogContext);
      },
    ),
  );
}

Future<void> _showTeacherGroupsDialog(
  BuildContext context,
  FirestoreDatabaseAdapter database,
  TeacherModel teacher,
) async {
  final selectedGroups = teacher.groupIds.toSet();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => _OriginalDialog(
        title: 'Grupos - ${teacher.name}',
        width: 420,
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final group in database.groups)
              FilterChip(
                selected: selectedGroups.contains(group.id),
                label: Text(group.name),
                selectedColor: AppColors.accent,
                backgroundColor: AppColors.card2,
                onSelected: (selected) {
                  setDialogState(() {
                    if (selected) {
                      selectedGroups.add(group.id);
                    } else if (selectedGroups.length > 1) {
                      selectedGroups.remove(group.id);
                    }
                  });
                },
              ),
          ],
        ),
        onSave: () {
          database.updateTeacherGroups(teacher.id, selectedGroups.toList());
          Navigator.pop(dialogContext);
        },
      ),
    ),
  );
}

Future<void> _confirm({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.background,
      title: Text(title),
      content: Text(message),
      actions: [
        FlatTextButton(
          label: 'Cancelar',
          background: AppColors.card,
          foreground: AppColors.mutedText,
          onPressed: () => Navigator.pop(dialogContext),
        ),
        FlatTextButton(
          label: 'Aceptar',
          background: AppColors.red,
          onPressed: () {
            onConfirm();
            Navigator.pop(dialogContext);
          },
        ),
      ],
    ),
  );
}

class _OriginalDialog extends StatelessWidget {
  const _OriginalDialog({
    required this.title,
    required this.child,
    required this.onSave,
    this.width = 380,
  });

  final String title;
  final Widget child;
  final VoidCallback onSave;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 3, color: AppColors.accent),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: AppColors.card,
              padding: const EdgeInsets.all(16),
              child: child,
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlatTextButton(
                    label: 'Cancelar',
                    background: AppColors.card,
                    foreground: AppColors.mutedText,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  FlatTextButton(label: 'Guardar', onPressed: onSave),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

