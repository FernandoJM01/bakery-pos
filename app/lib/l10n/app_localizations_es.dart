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
  String get validationFailed => 'Revisa los datos.';

  @override
  String get statusOnline => 'En línea';

  @override
  String get statusOffline => 'Sin conexión';

  @override
  String get navSales => 'Ventas';

  @override
  String get navCash => 'Caja';

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
  String backofficeLockedUntil(String time) {
    return 'Demasiados intentos. Bloqueado hasta las $time.';
  }

  @override
  String get backofficeTitle => 'Panel de Administración';

  @override
  String get backofficeNoPermissions =>
      'No tiene permisos para acceder a ninguna sección';

  @override
  String get branchesTitle => 'Sucursales';

  @override
  String get branchesNew => 'Nueva sucursal';

  @override
  String get branchesEdit => 'Editar sucursal';

  @override
  String get branchesCode => 'Código';

  @override
  String get branchesName => 'Nombre';

  @override
  String get branchesAddress => 'Dirección';

  @override
  String get branchesTimezone => 'Zona horaria';

  @override
  String get branchesStatus => 'Estado';

  @override
  String get branchesActive => 'Activa';

  @override
  String get branchesInactive => 'Inactiva';

  @override
  String get branchesCodeImmutable => 'El código no se puede modificar';

  @override
  String get branchesCodeInvalid =>
      'El código debe tener entre 2 y 10 caracteres alfanuméricos en mayúsculas';

  @override
  String get branchesNameRequired => 'El nombre es obligatorio';

  @override
  String get branchesNameInvalid =>
      'El nombre debe tener entre 1 y 120 caracteres';

  @override
  String get branchesTimezoneRequired => 'La zona horaria es obligatoria';

  @override
  String get branchesEmpty => 'No hay sucursales registradas';

  @override
  String get branchesCreateSuccess => 'Sucursal creada exitosamente';

  @override
  String get branchesUpdateSuccess => 'Sucursal actualizada exitosamente';

  @override
  String get branchesCodeConflict => 'Ya existe una sucursal con ese código';

  @override
  String get branchesErrorLoading => 'Error al cargar las sucursales';

  @override
  String get branchesSaving => 'Guardando...';

  @override
  String get timezoneMexicoCity => 'Centro (Ciudad de México)';

  @override
  String get timezoneCancun => 'Sureste (Cancún)';

  @override
  String get timezoneMerida => 'Centro (Mérida)';

  @override
  String get timezoneMonterrey => 'Centro (Monterrey)';

  @override
  String get timezoneMatamoros => 'Frontera Norte (Matamoros)';

  @override
  String get timezoneChihuahua => 'Montaña (Chihuahua)';

  @override
  String get timezoneCiudadJuarez => 'Frontera Norte (Ciudad Juárez)';

  @override
  String get timezoneOjinaga => 'Frontera Norte (Ojinaga)';

  @override
  String get timezoneMazatlan => 'Pacífico (Mazatlán)';

  @override
  String get timezoneBahiaBanderas => 'Centro (Bahía de Banderas)';

  @override
  String get timezoneHermosillo => 'Pacífico (Hermosillo)';

  @override
  String get timezoneTijuana => 'Noroeste (Tijuana)';

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
