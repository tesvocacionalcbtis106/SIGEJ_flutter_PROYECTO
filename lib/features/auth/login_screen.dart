import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/original_widgets.dart';
import '../../models/role_model.dart';
import 'auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.loginBg,
      body: Column(
        children: [
          Container(height: 5, color: AppColors.accent),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 410,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      color: AppColors.accent,
                      alignment: Alignment.center,
                      child: const Text('📋', style: TextStyle(fontSize: 31)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sistema de Justificantes',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Control Escolar',
                      style: TextStyle(color: AppColors.mutedText, fontSize: 15),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      color: AppColors.loginCard,
                      padding: const EdgeInsets.fromLTRB(40, 30, 40, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(height: 3, color: AppColors.accent),
                          const SizedBox(height: 22),
                          const _FieldLabel('USUARIO'),
                          _LoginField(controller: _usernameController),
                          const SizedBox(height: 14),
                          const _FieldLabel('CONTRASEÑA'),
                          _LoginField(
                            controller: _passwordController,
                            obscureText: true,
                            onSubmitted: (_) => _submit(auth),
                          ),
                          const SizedBox(height: 22),
                          FlatTextButton(
                            label: '  INICIAR SESION  →',
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            onPressed: auth.isLoading ? null : () => _submit(auth),
                          ),
                          SizedBox(
                            height: 28,
                            child: Center(
                              child: Text(
                                auth.error ?? '',
                                style: const TextStyle(
                                  color: AppColors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Sistema de Control Escolar  •  Acceso autorizado unicamente',
                      style: TextStyle(color: AppColors.mutedText, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(AuthController auth) async {
    final ok = await auth.login(
      _usernameController.text,
      _passwordController.text,
    );
    if (!ok || !mounted) return;

    final role = auth.currentUser!.role;
    if (role == UserRole.superAdmin) {
      context.go(AppRoutes.admin);
    } else if (role == UserRole.admin) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.reports);
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.mutedText,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    this.obscureText = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: AppColors.white),
      cursorColor: AppColors.white,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      ),
    );
  }
}
