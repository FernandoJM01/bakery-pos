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

  @override
  String get commonRefresh => 'Actualizar';

  @override
  String get adminConflict => 'Ya existe un registro con esos datos.';

  @override
  String get adminNotFound => 'Ya no existe. Actualiza la lista.';

  @override
  String get adminPermissionDenied => 'No tienes permiso para hacer esto.';

  @override
  String get allBranches => 'Todas las sucursales';

  @override
  String get allRoles => 'Todos los puestos';

  @override
  String get roleOwner => 'Dueño';

  @override
  String get roleBranchManager => 'Gerente de sucursal';

  @override
  String get roleCashier => 'Cajero';

  @override
  String get roleBaker => 'Panadero';

  @override
  String get staffTitle => 'Personal';

  @override
  String get staffNew => 'Nueva persona';

  @override
  String get staffEdit => 'Editar persona';

  @override
  String get staffFullName => 'Nombre completo';

  @override
  String get staffFullNameInvalid =>
      'Escribe el nombre completo (máximo 120 caracteres)';

  @override
  String get staffDisplayName => 'Nombre en la caja';

  @override
  String get staffDisplayNameHelp => 'Así aparece en la pantalla de PIN';

  @override
  String get staffDisplayNameInvalid =>
      'Escribe un nombre corto (máximo 30 caracteres)';

  @override
  String get staffRole => 'Puesto';

  @override
  String get staffBranch => 'Sucursal';

  @override
  String get staffBranches => 'Sucursales';

  @override
  String get staffBranchesRequired => 'Elige al menos una sucursal';

  @override
  String get staffEmail => 'Correo';

  @override
  String get staffEmailOptional =>
      'Correo (opcional, para entrar a la administración)';

  @override
  String get staffEmailRequired =>
      'El correo es obligatorio para entrar a la administración';

  @override
  String get staffEmailInvalid => 'Escribe un correo válido';

  @override
  String get staffPassword => 'Contraseña';

  @override
  String get staffNewPasswordOptional =>
      'Nueva contraseña (déjala vacía para no cambiarla)';

  @override
  String get staffPasswordHelp =>
      'Mínimo 10 caracteres. Cambiarla cierra sus sesiones abiertas.';

  @override
  String get staffPasswordRequired => 'El dueño necesita contraseña';

  @override
  String get staffPasswordTooShort =>
      'La contraseña debe tener al menos 10 caracteres';

  @override
  String get staffPin => 'PIN (4 a 6 dígitos)';

  @override
  String get staffPinConfirm => 'Repite el PIN';

  @override
  String get staffPinInvalid => 'El PIN debe tener de 4 a 6 dígitos';

  @override
  String get staffPinMismatch => 'Los PIN no coinciden';

  @override
  String get staffShowInactive => 'Mostrar dados de baja';

  @override
  String get staffActive => 'Activo';

  @override
  String get staffInactive => 'Dado de baja';

  @override
  String get staffLocked => 'Bloqueado';

  @override
  String get staffEmpty => 'No hay personal con estos filtros';

  @override
  String get staffErrorLoading => 'Error al cargar el personal';

  @override
  String get staffCreated => 'Persona agregada';

  @override
  String get staffUpdated => 'Cambios guardados';

  @override
  String get staffResetPin => 'Cambiar PIN';

  @override
  String get staffResetPinMessage =>
      'El nuevo PIN funciona de inmediato. Se desbloquea la cuenta y se cierran sus sesiones abiertas.';

  @override
  String get staffPinChanged => 'PIN cambiado';

  @override
  String get staffDeactivate => 'Dar de baja';

  @override
  String get staffReactivate => 'Reactivar';

  @override
  String get staffDeactivateMessage =>
      'Ya no podrá entrar a ninguna caja ni a la administración y se cierran sus sesiones abiertas. Su historial se conserva y puedes reactivarla después.';

  @override
  String get staffDeactivated => 'Persona dada de baja';

  @override
  String get staffReactivated => 'Persona reactivada';

  @override
  String get staffEmailConflict => 'Ese correo ya lo usa otra persona';

  @override
  String get staffLastOwner =>
      'No se puede: debe quedar al menos un dueño activo';

  @override
  String get devicesTitle => 'Dispositivos';

  @override
  String get deviceNew => 'Nuevo dispositivo';

  @override
  String get deviceName => 'Nombre';

  @override
  String get deviceNameHelp => 'Por ejemplo: Caja 1, Mostrador';

  @override
  String get deviceNameInvalid => 'Escribe un nombre (máximo 60 caracteres)';

  @override
  String get deviceType => 'Tipo';

  @override
  String get deviceTypeTill => 'Caja';

  @override
  String get deviceTypeProduction => 'Producción';

  @override
  String get deviceLastSeen => 'Última conexión';

  @override
  String get deviceShowRevoked => 'Mostrar revocados';

  @override
  String get deviceStatusActive => 'Activo';

  @override
  String get deviceStatusPending => 'Esperando código';

  @override
  String get deviceStatusRevoked => 'Revocado';

  @override
  String get deviceBranchRequired => 'Elige la sucursal';

  @override
  String get deviceBranchInactive =>
      'No se pudo registrar: revisa que la sucursal esté activa.';

  @override
  String get deviceCreateAndGetCode => 'Registrar y ver código';

  @override
  String get deviceNewCode => 'Nuevo código';

  @override
  String get deviceNewCodeMessage => 'El código anterior deja de funcionar.';

  @override
  String get deviceRevoke => 'Revocar';

  @override
  String get deviceRevokeMessage =>
      'El dispositivo se desconecta de inmediato y ya no podrá usarse. Para volver a usarlo hay que registrarlo como nuevo.';

  @override
  String get deviceRevoked => 'Dispositivo revocado';

  @override
  String get deviceCopyCode => 'Copiar';

  @override
  String get deviceCodeDone => 'Ya lo anoté';

  @override
  String get devicesEmpty => 'No hay dispositivos con estos filtros';

  @override
  String get devicesErrorLoading => 'Error al cargar los dispositivos';

  @override
  String get auditTitle => 'Auditoría';

  @override
  String get auditAction => 'Acción';

  @override
  String get auditAllActions => 'Todas las acciones';

  @override
  String get auditPerson => 'Persona';

  @override
  String get auditAllPeople => 'Todas las personas';

  @override
  String get auditAnyDate => 'Cualquier fecha';

  @override
  String get auditClearDates => 'Quitar fechas';

  @override
  String get auditEmpty => 'No hay movimientos con estos filtros';

  @override
  String get auditLoadMore => 'Cargar más';

  @override
  String get auditSystem => 'Sistema';

  @override
  String get auditUnknownPerson => 'Persona desconocida';

  @override
  String get auditLoginSuccess => 'Inicio de sesión';

  @override
  String get auditLoginFailure => 'Intento fallido de inicio de sesión';

  @override
  String get auditLocked => 'Cuenta bloqueada por intentos';

  @override
  String get auditLogout => 'Cierre de sesión';

  @override
  String get auditApprovalGranted => 'Autorización de gerente concedida';

  @override
  String get auditApprovalDenied => 'Autorización de gerente rechazada';

  @override
  String get auditStaffCreated => 'Persona agregada';

  @override
  String get auditStaffUpdated => 'Persona modificada';

  @override
  String get auditStaffDeactivated => 'Persona dada de baja';

  @override
  String get auditStaffPinChanged => 'PIN cambiado';

  @override
  String get auditDeviceCreated => 'Dispositivo registrado';

  @override
  String get auditDeviceActivated => 'Dispositivo activado';

  @override
  String get auditDeviceRevoked => 'Dispositivo revocado';

  @override
  String get auditBranchCreated => 'Sucursal creada';

  @override
  String get auditBranchUpdated => 'Sucursal modificada';

  @override
  String staffDeactivateTitle(String name) {
    return '¿Dar de baja a $name?';
  }

  @override
  String staffResetPinTitle(String name) {
    return 'Cambiar el PIN de $name';
  }

  @override
  String deviceNewCodeTitle(String name) {
    return '¿Nuevo código para $name?';
  }

  @override
  String deviceRevokeTitle(String name) {
    return '¿Revocar $name?';
  }

  @override
  String deviceCodeTitle(String name) {
    return 'Código para $name';
  }

  @override
  String deviceCodeInstructions(String time) {
    return 'Escribe este código en la tableta al abrir la app. Vence a las $time y solo se muestra esta vez.';
  }

  @override
  String auditApprovedBy(String name) {
    return 'autorizó $name';
  }

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsAppearanceBreadcrumb => 'Ajustes · Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeEspresso => 'Espresso';

  @override
  String get settingsThemeEspressoDesc => 'Oscuro cálido';

  @override
  String get settingsThemeCrema => 'Crema';

  @override
  String get settingsThemeCremaDesc => 'Claro suave';

  @override
  String get settingsThemeHighContrast => 'Alto contraste';

  @override
  String get settingsThemeHighContrastDesc => 'Máxima legibilidad';

  @override
  String get settingsThemeSystem => 'Automático';

  @override
  String get settingsThemeSystemDesc => 'Sigue al sistema';

  @override
  String get settingsAccentColor => 'Color de acento';

  @override
  String get settingsAccentAmber => 'Ámbar';

  @override
  String get settingsAccentWheat => 'Trigo';

  @override
  String get settingsAccentTerracotta => 'Terracota';

  @override
  String get settingsAccentMint => 'Menta';

  @override
  String get settingsAccentBerry => 'Mora';

  @override
  String get settingsTextSize => 'Tamaño de texto';

  @override
  String get settingsTextSizeNormal => 'Normal';

  @override
  String get settingsTextSizeLarge => 'Grande';

  @override
  String get settingsTextSizeExtraLarge => 'Muy grande';

  @override
  String get settingsButtonStyle => 'Estilo de botón de producto';

  @override
  String get settingsButtonStylePhotoAndName => 'Foto y nombre';

  @override
  String get settingsButtonStyleNameOnly => 'Solo nombre';

  @override
  String get settingsPreview => 'Vista previa';

  @override
  String get settingsPreviewProductName => 'Concha de vainilla';

  @override
  String get settingsPreviewProductPrice => '\$15.00';

  @override
  String get settingsPreviewSampleButton => 'Botón de muestra';

  @override
  String get settingsSaved => 'Ajustes guardados';
}
