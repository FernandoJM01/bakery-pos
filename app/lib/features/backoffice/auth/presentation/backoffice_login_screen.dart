import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/auth/data/backoffice_auth_service.dart';
import 'package:bakery_pos/features/backoffice/auth/domain/backoffice_auth_exceptions.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackofficeLoginScreen extends ConsumerStatefulWidget {
  const BackofficeLoginScreen({super.key});

  @override
  ConsumerState<BackofficeLoginScreen> createState() =>
      _BackofficeLoginScreenState();
}

class _BackofficeLoginScreenState extends ConsumerState<BackofficeLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final l10n = AppLocalizations.of(context)!;
    final authService = ref.read(backofficeAuthServiceProvider);

    try {
      await authService.login(_emailController.text, _passwordController.text);
    } on BackofficeAuthInvalidCredentialsException {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.backofficeInvalidCredentials;
        });
      }
    } on BackofficeAuthLockedException catch (e) {
      if (mounted) {
        final time = e.lockedUntil != null
            ? '${e.lockedUntil!.toLocal().hour.toString().padLeft(2, '0')}:${e.lockedUntil!.toLocal().minute.toString().padLeft(2, '0')}'
            : '';
        setState(() {
          _errorMessage = l10n.backofficeLockedUntil(time);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.enrollmentNetworkError;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.appTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryAmber,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Text(
                        l10n.backofficeLoginTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.alertRedBg,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSmall,
                            ),
                            border: Border.all(color: AppColors.alertRed),
                          ),
                          child: Text(
                            _errorMessage!,
                            key: const Key('backoffice-error-text'),
                            style: const TextStyle(color: AppColors.alertRed),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                      ],
                      TextFormField(
                        key: const Key('backoffice-email-input'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.backofficeEmailLabel,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.enrollmentValidationFailed;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      TextFormField(
                        key: const Key('backoffice-password-input'),
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          labelText: l10n.backofficePasswordLabel,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.enrollmentValidationFailed;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      SizedBox(
                        height: AppDimensions.preferredTouchTarget,
                        child: ElevatedButton(
                          key: const Key('backoffice-login-button'),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.backofficeLoginButton),
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
