// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Bakery POS';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonAccept => 'Aceptar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonLogout => 'Cerrar sesión';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonBack => 'Regresar';

  @override
  String get statusOnline => 'En línea';

  @override
  String get statusOffline => 'Sin conexión';

  @override
  String get navSales => 'Ventas';

  @override
  String get navCash => 'Caja';

  @override
  String get navShift => 'Turno';

  @override
  String get navProduction => 'Producción';

  @override
  String get navOrders => 'Pedidos';

  @override
  String get navOven => 'Horno';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get navStaff => 'Personal';

  @override
  String get navDevices => 'Dispositivos';

  @override
  String get navBranches => 'Sucursales';

  @override
  String get navReports => 'Reportes';

  @override
  String get navAudit => 'Auditoría';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get enrollmentTitle => 'Inscripción de Dispositivo';

  @override
  String get enrollmentSubtitle =>
      'Ingresa el código generado en el portal de administración';

  @override
  String get enrollmentCodeLabel => 'Código de inscripción';

  @override
  String get enrollmentCodeHint => 'Ej. 8 caracteres';

  @override
  String get enrollmentServerUrlLabel => 'URL del servidor';

  @override
  String get enrollmentServerUrlHint => 'http://localhost:3000';

  @override
  String get enrollmentSubmitButton => 'Inscribir dispositivo';

  @override
  String get enrollmentSubmitting => 'Inscribiendo...';

  @override
  String get enrollmentSuccess => 'Dispositivo inscrito correctamente';

  @override
  String get enrollmentCodeInvalid => 'El código es inválido o ha expirado';

  @override
  String get enrollmentRateLimited =>
      'Demasiados intentos. Espera unos minutos e intenta de nuevo.';

  @override
  String get enrollmentValidationFailed => 'Revisa el código ingresado.';

  @override
  String get enrollmentNetworkError =>
      'Error de conexión con el servidor. Verifique la URL y la red.';

  @override
  String get enrollmentInvalidUrl =>
      'Ingrese una URL válida (ej. http://192.168.1.100:3000)';

  @override
  String get enrollmentCodeRequired =>
      'El código debe tener exactamente 8 caracteres';

  @override
  String get loginSelectStaff => 'Selecciona tu usuario';

  @override
  String get loginEnterPin => 'Ingresa tu PIN';

  @override
  String get loginPinHint => 'PIN de 4 a 6 dígitos';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginInvalidPin => 'PIN incorrecto';

  @override
  String get loginLocked =>
      'Demasiados intentos fallidos. Bloqueado temporalmente.';

  @override
  String loginLockedUntil(String time) {
    return 'Demasiados intentos. Bloqueado hasta las $time.';
  }

  @override
  String get loginStaffNotAllowed =>
      'Usuario no autorizado en esta sucursal o inactivo';

  @override
  String get loginOfflineSession => 'Sesión sin conexión';

  @override
  String get loginNoStaff =>
      'No hay personal disponible. Sincroniza el dispositivo.';

  @override
  String get loginSyncSuccess => 'Personal sincronizado correctamente';

  @override
  String get loginSyncFailed => 'Error al sincronizar personal con el servidor';

  @override
  String get backofficeLoginTitle => 'Acceso a Administración';

  @override
  String get backofficeEmailLabel => 'Correo electrónico';

  @override
  String get backofficePasswordLabel => 'Contraseña';

  @override
  String get backofficeLoginButton => 'Iniciar sesión';

  @override
  String get backofficeInvalidCredentials => 'Credenciales inválidas';

  @override
  String get approvalTitle => 'Aprobación de Gerente';

  @override
  String get approvalPinPrompt =>
      'Ingrese PIN de gerente para aprobar esta acción';

  @override
  String get approvalGranted => 'Acción aprobada';

  @override
  String get approvalDenied => 'Aprobación denegada';

  @override
  String get approvalSelectApprover => 'Selecciona quién autoriza';

  @override
  String get approvalNoApprovers =>
      'No hay personal con permiso para autorizar esta acción';

  @override
  String get approvalPermissionDenied =>
      'El usuario no tiene permiso para autorizar esta acción';

  @override
  String get approvalInvalidPin => 'PIN incorrecto';

  @override
  String get approvalLocked => 'Demasiados intentos. Bloqueado temporalmente.';

  @override
  String approvalLockedUntil(String time) {
    return 'Demasiados intentos. Bloqueado hasta las $time.';
  }

  @override
  String get debugOpenDrawerNoSale => 'Abrir cajón sin venta (demo)';

  @override
  String get deviceRevokedTitle => 'Dispositivo revocado';

  @override
  String get deviceRevokedMessage =>
      'Este dispositivo ha sido revocado. Los datos locales serán eliminados.';

  @override
  String get placeholderSectionTitle => 'Sección en desarrollo';

  @override
  String get placeholderSectionMessage =>
      'Esta funcionalidad estará disponible en un próximo hito.';
}
