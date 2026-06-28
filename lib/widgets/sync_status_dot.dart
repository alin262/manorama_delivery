import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';

class SyncStatusDot extends ConsumerWidget {
  const SyncStatusDot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);

    Color dotColor;
    String tooltip;

    switch (status) {
      case 'saving':
        dotColor = AppTheme.warning;
        tooltip = 'Saving...';
        break;
      case 'saved':
        dotColor = AppTheme.success;
        tooltip = 'Saved!';
        break;
      case 'error':
        dotColor = AppTheme.danger;
        tooltip = 'Error saving!';
        break;
      default:
        dotColor = AppTheme.textSecondary;
        tooltip = 'No changes';
    }

    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: dotColor.withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}