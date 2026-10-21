import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/device_activate_request.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';

class EnrollmentScreen extends ConsumerStatefulWidget {
  const EnrollmentScreen({super.key, this.isRevoked = false});

  final bool isRevoked;

  @override
  ConsumerState<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends ConsumerState<EnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final currentBaseUrl = ref.read(serverBaseUrlProvider);
    _urlController = TextEditingController(text: currentBaseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final serverUrl = _urlController.text.trim();
    final code = _codeController.text.trim().toUpperCase();

    setState(() => _isLoading = true);

    try {
      ref.read(serverBaseUrlProvider.notifier).setBaseUrl(serverUrl);

      final client = ref.read(restClientProvider);
      final response = await client.devices.activateDevice(
        body: DeviceActivateRequest(enrollmentCode: code, appVersion: '1.0.0'),
      );

      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.saveServerUrl(serverUrl);
      await secureStorage.saveEnrolledDevice(
        deviceToken: response.deviceToken,
        deviceJson: jsonEncode(response.device.toJson()),
        branchJson: jsonEncode(response.branch.toJson()),
      );

      if (mounted) {
        context.go(AppRoutes.tillLogin);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      String? errorCode;
      if (data is Map<String, dynamic>) {
        errorCode = data['code'] as String?;
      }

      if (e.response?.statusCode == 410 || errorCode == 'DEVICE_CODE_INVALID') {
        setState(() => _errorMessage = l10n.enrollmentCodeInvalid);
      } else if (e.response?.statusCode == 429 || errorCode == 'RATE_LIMITED') {
        setState(() => _errorMessage = l10n.enrollmentRateLimited);
      } else if (e.response?.statusCode == 400 ||
          errorCode == 'VALIDATION_FAILED') {
        setState(() => _errorMessage = l10n.enrollmentValidationFailed);
      } else {
        setState(() => _errorMessage = l10n.enrollmentNetworkError);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = l10n.enrollmentNetworkError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                side: const BorderSide(color: AppColors.surfaceHighlight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.point_of_sale_rounded,
                        size: 48,
                        color: AppColors.primaryAmber,
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      Text(
                        l10n.enrollmentTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Text(
                        l10n.enrollmentSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      if (widget.isRevoked) ...[
                        Container(
                          key: const Key('enrollment-revoked-banner'),
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.alertRedBg,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium,
                            ),
                            border: Border.all(color: AppColors.alertRed),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.deviceRevokedTitle,
                                style: const TextStyle(
                                  color: AppColors.alertRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.deviceRevokedMessage,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                      ],
                      if (_errorMessage != null) ...[
                        Container(
                          key: const Key('enrollment-error-banner'),
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.alertRedBg,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium,
                            ),
                            border: Border.all(color: AppColors.alertRed),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.alertRed),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                      ],
                      TextFormField(
                        key: const Key('enrollment-server-url-field'),
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: l10n.enrollmentServerUrlLabel,
                          hintText: l10n.enrollmentServerUrlHint,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.enrollmentInvalidUrl;
                          }
                          final uri = Uri.tryParse(value.trim());
                          if (uri == null ||
                              !uri.hasScheme ||
                              uri.host.isEmpty) {
                            return l10n.enrollmentInvalidUrl;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      TextFormField(
                        key: const Key('enrollment-code-field'),
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-hj-np-z2-9A-HJ-NP-Z]'),
                          ),
                          TextInputFormatter.withFunction(
                            (oldValue, newValue) => newValue.copyWith(
                              text: newValue.text.toUpperCase(),
                            ),
                          ),
                          LengthLimitingTextInputFormatter(8),
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.enrollmentCodeLabel,
                          hintText: l10n.enrollmentCodeHint,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length != 8) {
                            return l10n.enrollmentCodeRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      SizedBox(
                        height: AppDimensions.preferredTouchTarget,
                        child: ElevatedButton(
                          key: const Key('enrollment-submit-button'),
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: AppDimensions.paddingSmall,
                                    ),
                                    Text(l10n.enrollmentSubmitting),
                                  ],
                                )
                              : Text(l10n.enrollmentSubmitButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
