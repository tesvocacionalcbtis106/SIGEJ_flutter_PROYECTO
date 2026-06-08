enum UserRole {
  superAdmin('SUPER_ADMIN'),
  admin('ADMIN'),
  maestro('MAESTRO');

  const UserRole(this.label);

  final String label;
}

