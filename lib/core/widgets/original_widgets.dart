import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/auth_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';

class OriginalHeader extends StatelessWidget {
  const OriginalHeader({
    super.key,
    required this.roleText,
    required this.roleColor,
    required this.name,
    this.backLabel,
    this.onBack,
  });

  final String roleText;
  final Color roleColor;
  final String name;
  final String? backLabel;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: AppColors.panel,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  roleText,
                  style: TextStyle(
                    color: roleColor,
                    fontFamily: 'Consolas',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (backLabel != null)
            FlatTextButton(
              label: backLabel!,
              foreground: AppColors.accent,
              background: AppColors.panel,
              onPressed: onBack,
            ),
          const SizedBox(width: 6),
          FlatTextButton(
            label: 'Cerrar sesion',
            foreground: AppColors.mutedText,
            background: AppColors.panel,
            onPressed: () async {
              await context.read<AuthController>().logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
    );
  }
}

class FlatTextButton extends StatelessWidget {
  const FlatTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.background = AppColors.accent,
    this.foreground = AppColors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
  });

  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: padding,
        shape: const RoundedRectangleBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

class AccentSectionLabel extends StatelessWidget {
  const AccentSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

class OriginalTable extends StatelessWidget {
  const OriginalTable({
    super.key,
    required this.columns,
    required this.rows,
    this.flexes,
    this.onRowTap,
    this.selectedIndex,
  });

  final List<String> columns;
  final List<List<String>> rows;
  final List<int>? flexes;
  final ValueChanged<int>? onRowTap;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final effectiveFlexes = flexes ?? List.filled(columns.length, 1);

    return ClipRect(
      child: Column(
        children: [
          Container(
            height: 38,
            color: AppColors.accent2,
            child: Row(
              children: [
                for (var i = 0; i < columns.length; i++)
                  Expanded(
                    flex: effectiveFlexes[i],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        columns[i],
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                return InkWell(
                  onTap: onRowTap == null ? null : () => onRowTap!(index),
                  child: Container(
                    height: 34,
                    color: selectedIndex == index
                        ? AppColors.selected
                        : index.isEven
                            ? AppColors.rowEven
                            : AppColors.rowOdd,
                    child: Row(
                      children: [
                        for (var i = 0; i < row.length; i++)
                          Expanded(
                            flex: effectiveFlexes[i],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                row[i],
                                style: const TextStyle(color: AppColors.text),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TopStripeCard extends StatelessWidget {
  const TopStripeCard({
    super.key,
    required this.color,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Color color;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: color),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
