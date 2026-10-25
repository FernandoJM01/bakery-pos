import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// The contract error code of a failed call, or null for network errors.
String? apiErrorCode(Object error) {
  if (error is! DioException) return null;
  final data = error.response?.data;
  return data is Map ? data['code']?.toString() : null;
}

String? apiErrorMessage(Object error) {
  if (error is! DioException) return null;
  final data = error.response?.data;
  return data is Map ? data['message']?.toString() : null;
}

/// Spanish text for errors every admin form shares.
String commonAdminError(AppLocalizations l10n, Object error) {
  switch (apiErrorCode(error)) {
    case 'VALIDATION_FAILED':
      return l10n.validationFailed;
    case 'PERMISSION_DENIED':
      return l10n.adminPermissionDenied;
    case 'NOT_FOUND':
      return l10n.adminNotFound;
    case 'CONFLICT':
      return l10n.adminConflict;
    default:
      return l10n.enrollmentNetworkError;
  }
}

class AdminErrorBanner extends StatelessWidget {
  const AdminErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.alertRedBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.alertRed),
      ),
      child: Text(
        message,
        key: const Key('admin-dialog-error'),
        style: const TextStyle(color: AppColors.alertRed),
      ),
    );
  }
}

/// Asks before a destructive step. Returns true only on an explicit confirm.
Future<bool> confirmAdminAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Text(message),
      ),
      actions: [
        TextButton(
          key: const Key('confirm-cancel-button'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          key: const Key('confirm-accept-button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.alertRed,
            foregroundColor: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}

class AdminStatusChip extends StatelessWidget {
  const AdminStatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), backgroundColor: color);
  }
}

String _two(int n) => n.toString().padLeft(2, '0');

/// 25/10/2026 14:05 in the browser's local time.
String formatAdminDateTime(DateTime value) {
  final t = value.toLocal();
  return '${_two(t.day)}/${_two(t.month)}/${t.year} ${formatAdminTime(t)}';
}

String formatAdminTime(DateTime value) {
  final t = value.toLocal();
  return '${_two(t.hour)}:${_two(t.minute)}';
}
