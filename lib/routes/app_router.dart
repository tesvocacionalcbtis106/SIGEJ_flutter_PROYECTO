import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../features/admin/admin_screen.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/users/user_form_screen.dart';
import '../features/users/users_screen.dart';
import '../models/role_model.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final auth = context.read<AuthController>();
      final location = state.uri.path;
      final isLogin = location == AppRoutes.login;

      if (!auth.isAuthenticated) {
        return isLogin ? null : AppRoutes.login;
      }

      final role = auth.currentUser!.role;
      if (isLogin) return _homeFor(role);

      if (!_canAccess(role, location)) {
        return _homeFor(role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.users,
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.userForm,
        builder: (context, state) => UserFormScreen(
          studentId: state.uri.queryParameters['studentId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (context, state) => const ReportsScreen(),
      ),
    ],
  );

  static String _homeFor(UserRole role) {
    return switch (role) {
      UserRole.superAdmin => AppRoutes.admin,
      UserRole.admin => AppRoutes.dashboard,
      UserRole.maestro => AppRoutes.reports,
    };
  }

  static bool _canAccess(UserRole role, String location) {
    return switch (role) {
      UserRole.superAdmin => location == AppRoutes.admin,
      UserRole.admin => location == AppRoutes.dashboard ||
          location == AppRoutes.users ||
          location == AppRoutes.userForm,
      UserRole.maestro => location == AppRoutes.reports,
    };
  }
}
