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

  @override
  String get catalogTitle => 'Catálogo';

  @override
  String get catalogTabProducts => 'Productos';

  @override
  String get catalogTabCategories => 'Categorías';

  @override
  String get catalogTabTaxes => 'Impuestos';

  @override
  String get catalogSearchHint => 'Buscar por nombre, SKU o código de barras';

  @override
  String get catalogAllCategories => 'Todas las categorías';

  @override
  String get catalogShowInactive => 'Mostrar inactivos';

  @override
  String get catalogNewProduct => 'Nuevo producto';

  @override
  String get catalogEditProduct => 'Editar producto';

  @override
  String get catalogNoProducts => 'No hay productos con estos filtros';

  @override
  String get catalogErrorLoading => 'No se pudo cargar el catálogo';

  @override
  String get catalogInactive => 'Inactivo';

  @override
  String catalogVariantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variantes',
      one: '1 variante',
    );
    return '$_temp0';
  }

  @override
  String get catalogNewCategory => 'Nueva categoría';

  @override
  String get catalogEditCategory => 'Editar categoría';

  @override
  String get catalogNoCategories => 'Aún no hay categorías';

  @override
  String get catalogCategoryName => 'Nombre de la categoría';

  @override
  String get catalogCategoryColor => 'Color';

  @override
  String get catalogCategoryNoColor => 'Sin color';

  @override
  String get catalogMoveUp => 'Subir';

  @override
  String get catalogMoveDown => 'Bajar';

  @override
  String get catalogActive => 'Activo';

  @override
  String get catalogNewTaxRate => 'Nuevo impuesto';

  @override
  String get catalogEditTaxRate => 'Editar impuesto';

  @override
  String get catalogTaxKind => 'Tipo';

  @override
  String get catalogTaxName => 'Nombre';

  @override
  String get catalogTaxRatePercent => 'Tasa (%)';

  @override
  String get catalogTaxRateInvalid => 'Escribe una tasa entre 0 y 100';

  @override
  String get catalogTaxInUse =>
      'Este impuesto lo usan productos; cámbialos antes de desactivarlo';

  @override
  String get catalogTaxPlaceholderNote =>
      'Las tasas son provisionales hasta que el contador las confirme.';

  @override
  String get catalogProductName => 'Nombre del producto';

  @override
  String get catalogProductCategory => 'Categoría';

  @override
  String get catalogProductUnit => 'Unidad';

  @override
  String get catalogUnitPiece => 'Pieza';

  @override
  String get catalogUnitKg => 'Kilo';

  @override
  String get catalogUnitPackage => 'Paquete';

  @override
  String get catalogProductDescription => 'Descripción (opcional)';

  @override
  String get catalogIva => 'IVA';

  @override
  String get catalogIeps => 'IEPS';

  @override
  String get catalogNoIeps => 'Sin IEPS';

  @override
  String get catalogPhoto => 'Foto';

  @override
  String get catalogPhotoChoose => 'Elegir foto';

  @override
  String get catalogPhotoRemove => 'Quitar foto';

  @override
  String get catalogPhotoNone => 'Sin foto';

  @override
  String get catalogDayOld => 'Pan del día anterior';

  @override
  String get catalogDayOldDiscountDays => 'Descuento después de (días)';

  @override
  String get catalogDayOldDiscountPercent => 'Descuento (%)';

  @override
  String get catalogDayOldWasteDays => 'Merma después de (días)';

  @override
  String get catalogDayOldPair =>
      'Escribe los días y el porcentaje de descuento juntos, o deja ambos vacíos';

  @override
  String get catalogDayOldWasteAfter =>
      'Los días de merma deben ser más que los días de descuento';

  @override
  String get catalogDayOldInvalid => 'Escribe un número entero';

  @override
  String get catalogVariants => 'Variantes';

  @override
  String get catalogAddVariant => 'Agregar variante';

  @override
  String get catalogRemoveVariant => 'Quitar variante';

  @override
  String get catalogVariantName => 'Variante';

  @override
  String get catalogVariantPrice => 'Precio';

  @override
  String get catalogVariantSku => 'SKU';

  @override
  String get catalogVariantBarcode => 'Código de barras';

  @override
  String catalogBranchPrice(String branch) {
    return 'Precio en $branch';
  }

  @override
  String get catalogBranchPriceHint => 'Igual que el precio base';

  @override
  String get catalogNeedsVariant =>
      'El producto necesita al menos una variante';

  @override
  String get catalogRequired => 'Obligatorio';

  @override
  String get catalogPriceInvalid => 'Escribe un precio como 12.50';

  @override
  String catalogTaxSplit(String base, String ieps, String iva) {
    return 'Base $base · IEPS $ieps · IVA $iva';
  }

  @override
  String get catalogSkuInUse => 'Ese SKU ya lo usa otra variante';

  @override
  String get catalogBarcodeInUse =>
      'Ese código de barras ya lo usa otra variante';

  @override
  String get catalogNameInUse =>
      'Ya existe una categoría activa con ese nombre';

  @override
  String get catalogNeedsActiveVariant =>
      'Un producto activo necesita al menos una variante activa';

  @override
  String get catalogSaved => 'Producto guardado';

  @override
  String get catalogCategorySaved => 'Categoría guardada';

  @override
  String get catalogTaxSaved => 'Impuesto guardado';

  @override
  String get catalogPhotoUploadFailed =>
      'No se pudo subir la foto. Usa una imagen JPG, PNG o WebP de hasta 5 MB.';

  @override
  String catalogProductSubtitle(String category, String variants) {
    return '$category · $variants';
  }

  @override
  String catalogTaxSubtitle(String kind, String rate) {
    return '$kind · $rate%';
  }

  @override
  String get navSync => 'Sincronización';

  @override
  String get syncAdminDevicesTitle => 'Dispositivos y última sincronización';

  @override
  String syncAdminDeviceLastSync(String when) {
    return 'Última sincronización: $when';
  }

  @override
  String get syncAdminDeviceNever => 'Todavía no se ha sincronizado';

  @override
  String get syncAdminQuarantineTitle => 'Registros en cuarentena';

  @override
  String get syncAdminQuarantineHelp =>
      'Registros que una caja envió y el servidor no pudo aplicar. Marcarlos como resueltos no los vuelve a aplicar.';

  @override
  String get syncAdminFilterOpen => 'Abiertos';

  @override
  String get syncAdminFilterResolved => 'Resueltos';

  @override
  String get syncAdminFilterAll => 'Todos';

  @override
  String get syncAdminEmpty => 'No hay registros en cuarentena';

  @override
  String syncAdminEntrySubtitle(
    String device,
    String occurred,
    String received,
  ) {
    return '$device · ocurrió $occurred · recibido $received';
  }

  @override
  String get syncAdminUnknownDevice => 'Dispositivo desconocido';

  @override
  String syncAdminErrorLine(String code, String message) {
    return '$code: $message';
  }

  @override
  String syncAdminResolvedLine(String when, String note) {
    return 'Resuelto el $when: $note';
  }

  @override
  String get syncAdminResolve => 'Marcar resuelto';

  @override
  String get syncAdminResolveTitle => 'Marcar registro como resuelto';

  @override
  String get syncAdminResolveHelp =>
      'El registro no se vuelve a aplicar. Anota qué se hizo con él.';

  @override
  String get syncAdminNote => 'Nota';

  @override
  String get syncAdminNoteRequired => 'Escribe una nota';

  @override
  String get syncAdminResolved => 'Registro marcado como resuelto';

  @override
  String get syncAdminAlreadyResolved => 'Este registro ya estaba resuelto';

  @override
  String get syncAdminLoadMore => 'Cargar más';

  @override
  String get gridAll => 'Todo';

  @override
  String get gridSearchHint => 'Buscar por nombre, SKU o código';

  @override
  String get gridEmpty => 'Aún no hay productos en esta caja';

  @override
  String get gridRefresh => 'Sincronizar';

  @override
  String get gridNoMatches => 'Ningún producto coincide';

  @override
  String gridPriceFrom(String price) {
    return 'Desde $price';
  }

  @override
  String get syncOnline => 'En línea';

  @override
  String get syncOffline => 'Sin conexión';

  @override
  String syncWaiting(int count) {
    return '$count en espera';
  }

  @override
  String get syncTitle => 'Sincronización';

  @override
  String syncWaitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros en espera',
      one: '1 registro en espera',
      zero: 'Nada en espera',
    );
    return '$_temp0';
  }

  @override
  String syncQuarantinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros en cuarentena',
      one: '1 registro en cuarentena',
      zero: 'Ningún registro en cuarentena',
    );
    return '$_temp0';
  }

  @override
  String get syncQuarantinedHelp =>
      'El servidor no pudo aplicar estos registros. El dueño los revisa en el panel, en Sincronización.';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get syncDone => 'Sincronizado';

  @override
  String get syncFailed =>
      'No se pudo conectar con el servidor; se reintentará solo';

  @override
  String get saleTicketTitle => 'Ticket';

  @override
  String get saleTicketEmpty => 'Toca un producto para agregarlo';

  @override
  String get saleClear => 'Vaciar ticket';

  @override
  String get saleClearTitle => '¿Vaciar el ticket?';

  @override
  String saleClearBody(int count) {
    return 'Se quitarán $count productos sin cobrar. Queda registrado.';
  }

  @override
  String get saleClearConfirm => 'Vaciar';

  @override
  String saleLineQuantityPrice(int quantity, String price) {
    return '$quantity × $price';
  }

  @override
  String get saleSubtotal => 'Subtotal';

  @override
  String get saleDiscounts => 'Descuentos';

  @override
  String get saleTotal => 'Total';

  @override
  String get saleDiscountButton => 'Descuento';

  @override
  String get salePay => 'Cobrar';

  @override
  String saleLineTitle(String product, String variant) {
    return '$product · $variant';
  }

  @override
  String get saleLineRemove => 'Quitar';

  @override
  String get saleLineDiscount => 'Descuento a esta línea';

  @override
  String get saleLineDone => 'Listo';

  @override
  String get saleNoFolio =>
      'Esta caja aún no tiene folio. Sincronízala con el servidor una vez para poder cobrar.';

  @override
  String saleDiscountLineTitle(String name) {
    return 'Descuento: $name';
  }

  @override
  String get saleDiscountTicketTitle => 'Descuento al ticket';

  @override
  String get saleDiscountPercent => '%';

  @override
  String get saleDiscountAmount => '\$';

  @override
  String get saleDiscountValuePercent => 'Porcentaje';

  @override
  String get saleDiscountValueAmount => 'Monto en pesos';

  @override
  String saleDiscountPreview(String amount) {
    return 'Descuenta $amount';
  }

  @override
  String get saleDiscountReason => 'Motivo';

  @override
  String get saleReasonFrequent => 'Cliente frecuente';

  @override
  String get saleReasonDamaged => 'Producto dañado';

  @override
  String get saleReasonPromotion => 'Promoción';

  @override
  String get saleReasonOther => 'Otro';

  @override
  String get saleDiscountNote => 'Nota';

  @override
  String get saleDiscountNoteRequired => 'Escribe una nota para el motivo Otro';

  @override
  String get saleDiscountInvalid =>
      'Escribe un descuento válido que no pase del importe';

  @override
  String saleDiscountOverLimit(String limit) {
    return 'Más de $limit necesita la autorización de un gerente';
  }

  @override
  String get saleDiscountApprovalNeeded =>
      'Sin la autorización de un gerente no se puede aplicar este descuento';

  @override
  String get saleDiscountApply => 'Aplicar';

  @override
  String get saleDiscountRemove => 'Quitar descuento';

  @override
  String get saleDiscountTicketLabel => 'Descuento al ticket';

  @override
  String get salePaymentTitle => 'Cobrar en efectivo';

  @override
  String get salePaymentTotal => 'Total a cobrar';

  @override
  String get salePaymentReceived => 'Recibido';

  @override
  String get salePaymentExact => 'Exacto';

  @override
  String get salePaymentChange => 'Cambio';

  @override
  String salePaymentMissing(String amount) {
    return 'Faltan $amount';
  }

  @override
  String get salePaymentFinish => 'Finalizar';

  @override
  String get salePaymentFailed =>
      'No se pudo guardar la venta. Inténtalo de nuevo.';

  @override
  String get receiptTitle => 'Venta registrada';

  @override
  String receiptFolio(String folio) {
    return 'Folio $folio';
  }

  @override
  String receiptCashier(String name) {
    return 'Atendió: $name';
  }

  @override
  String get receiptTaxIncluded => 'IVA incluido';

  @override
  String receiptTaxLine(String kind, String rate, String base, String tax) {
    return '$kind $rate: base $base, impuesto $tax';
  }

  @override
  String get receiptReceived => 'Recibido';

  @override
  String get receiptChange => 'Cambio';

  @override
  String get receiptNewSale => 'Nueva venta';

  @override
  String get saleDiscountReasonRequired => 'Elige un motivo';

  @override
  String receiptLineDiscountPercent(String percent) {
    return 'Descuento $percent';
  }

  @override
  String saleChooseVariantTitle(String product) {
    return '$product: elige la presentación';
  }

  @override
  String get saleHold => 'Guardar';

  @override
  String get saleHoldTitle => 'Guardar ticket';

  @override
  String get saleHoldName => 'Nombre (opcional)';

  @override
  String get saleHoldNameHint => 'Por ejemplo: Señora del rebozo';

  @override
  String saleHeldOpen(int count) {
    return 'En espera ($count)';
  }

  @override
  String get saleHeldTitle => 'Tickets en espera';

  @override
  String get saleHeldEmpty => 'No hay tickets en espera';

  @override
  String get saleHeldUnnamed => 'Ticket sin nombre';

  @override
  String saleHeldSubtitle(String time, int count, String total) {
    return '$time · $count productos · $total';
  }

  @override
  String get saleHeldResume => 'Retomar';

  @override
  String get saleHeldDiscard => 'Descartar';

  @override
  String get saleHeldBusy =>
      'Cobra o guarda el ticket actual antes de retomar otro';

  @override
  String get saleMenu => 'Más opciones';

  @override
  String get saleMenuRefund => 'Devolución';

  @override
  String get saleMenuVoid => 'Cancelar venta';

  @override
  String get refundFolio => 'Folio del ticket';

  @override
  String get refundFolioHint => 'Por ejemplo: SUC1-02-000153';

  @override
  String get refundSearch => 'Buscar';

  @override
  String get refundNotFound =>
      'No se encontró esa venta. Sin conexión solo se encuentran las ventas de esta caja.';

  @override
  String refundSaleTitle(String folio) {
    return 'Venta $folio';
  }

  @override
  String refundLineUnits(int left, int quantity) {
    return '$left de $quantity por devolver';
  }

  @override
  String get refundRestock => 'Vuelve al inventario';

  @override
  String get refundReason => 'Motivo';

  @override
  String get refundReasonCustomerReturn => 'El cliente lo devolvió';

  @override
  String get refundReasonWrongItem => 'Producto equivocado';

  @override
  String get refundReasonQuality => 'Calidad';

  @override
  String get refundReasonCashierError => 'Error de cobro';

  @override
  String get refundReasonOther => 'Otro';

  @override
  String get refundNote => 'Nota';

  @override
  String get refundNoteRequired => 'Escribe una nota para el motivo Otro';

  @override
  String get refundReasonRequired => 'Elige un motivo';

  @override
  String get refundNothing => 'Elige al menos una pieza';

  @override
  String refundGiveBack(String amount) {
    return 'Entregar $amount al cliente';
  }

  @override
  String get refundConfirm => 'Devolver';

  @override
  String get voidConfirm => 'Cancelar venta';

  @override
  String get refundApprovalNeeded =>
      'Sin la autorización de un gerente no se puede hacer';

  @override
  String refundTooMany(int lineNo, int left) {
    return 'En la línea $lineNo solo quedan $left piezas';
  }

  @override
  String get voidOtherTill =>
      'Solo se puede cancelar en la caja que hizo la venta';

  @override
  String get voidOtherDay => 'Solo se puede cancelar el mismo día de la venta';

  @override
  String get voidAlreadyReturned =>
      'Esta venta ya no tiene piezas por devolver';

  @override
  String get refundAlreadyReturned => 'Esta venta ya se devolvió completa';

  @override
  String get refundDoneTitle => 'Devolución registrada';

  @override
  String get voidDoneTitle => 'Venta cancelada';

  @override
  String get salesTitle => 'Ventas';

  @override
  String get salesFolioSearch => 'Buscar folio';

  @override
  String get salesEmpty => 'No hay ventas con estos filtros';

  @override
  String get salesLoadMore => 'Cargar más';

  @override
  String salesShownSummary(int count, String total, String refunded) {
    return '$count ventas mostradas · cobrado $total · devuelto $refunded';
  }

  @override
  String get salesForbidden => 'No tienes acceso a las ventas de esa sucursal';

  @override
  String get salesColFolio => 'Folio';

  @override
  String get salesColDate => 'Fecha';

  @override
  String get salesColCashier => 'Atendió';

  @override
  String get salesColStatus => 'Estado';

  @override
  String get salesColItems => 'Renglones';

  @override
  String get salesColTotal => 'Total';

  @override
  String get salesColRefunded => 'Devuelto';

  @override
  String get salesStatusCompleted => 'Completada';

  @override
  String get salesStatusPartiallyRefunded => 'Devolución parcial';

  @override
  String get salesStatusRefunded => 'Devuelta';

  @override
  String get salesStatusVoided => 'Cancelada';

  @override
  String salesDetailTitle(String folio) {
    return 'Venta $folio';
  }

  @override
  String salesDetailMeta(
    String date,
    String branch,
    String device,
    String cashier,
  ) {
    return '$date · $branch · $device · atendió $cashier';
  }

  @override
  String get salesDetailLines => 'Productos';

  @override
  String salesLineName(String product, String variant) {
    return '$product · $variant';
  }

  @override
  String salesLineQty(int quantity, String price) {
    return '$quantity × $price';
  }

  @override
  String salesLineDiscount(String amount) {
    return 'Descuento $amount';
  }

  @override
  String salesLineRefunded(int quantity) {
    return 'Devueltas: $quantity';
  }

  @override
  String get salesDetailDiscounts => 'Descuentos';

  @override
  String get salesDiscountOrder => 'A toda la venta';

  @override
  String salesDiscountLine(int lineNo) {
    return 'Al renglón $lineNo';
  }

  @override
  String salesDiscountRow(
    String scope,
    String value,
    String amount,
    String reason,
  ) {
    return '$scope: $value = $amount · $reason';
  }

  @override
  String salesDiscountApproved(String name) {
    return 'Autorizó: $name';
  }

  @override
  String get salesDetailTaxes => 'Impuestos por tasa';

  @override
  String get salesDetailPayment => 'Pago';

  @override
  String salesPaymentCash(String amount, String tendered, String change) {
    return 'Efectivo $amount · recibido $tendered · cambio $change';
  }

  @override
  String get salesDetailVoided => 'Quitados del ticket antes de cobrar';

  @override
  String salesVoidedRow(int quantity, String price, String time, String staff) {
    return '$quantity × $price · $time · $staff';
  }

  @override
  String get salesDetailRefunds => 'Devoluciones y cancelaciones';

  @override
  String get salesRefundKindRefund => 'Devolución';

  @override
  String get salesRefundKindVoid => 'Cancelación';

  @override
  String salesRefundRow(
    String kind,
    String date,
    String amount,
    String reason,
  ) {
    return '$kind · $date · $amount · $reason';
  }

  @override
  String salesRefundLineRow(int lineNo, int quantity, String amount) {
    return 'Renglón $lineNo: $quantity pza · $amount';
  }

  @override
  String get salesNone => 'Ninguno';

  @override
  String get salesGross => 'Subtotal';

  @override
  String get salesDiscountTotal => 'Descuentos';

  @override
  String get salesTotal => 'Total';

  @override
  String get salesRefundedTotal => 'Devuelto';

  @override
  String get deviceFolioPrefix => 'Prefijo de folio';

  @override
  String salesDateRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get cashLoadFailed => 'No se pudo leer el estado de la caja';

  @override
  String get cashOpenHint => 'Cuenta el fondo de caja para abrir el turno';

  @override
  String get cashOpen => 'Abrir turno';

  @override
  String cashFloatDiffers(String amount) {
    return 'El fondo no coincide con el último cierre ($amount)';
  }

  @override
  String cashShiftOpen(String date, String name) {
    return 'Turno abierto el $date por $name';
  }

  @override
  String cashFloatLine(String amount) {
    return 'Fondo: $amount';
  }

  @override
  String get cashIn => 'Entrada';

  @override
  String get cashOut => 'Salida';

  @override
  String get cashOpenDrawer => 'Abrir cajón';

  @override
  String get cashClose => 'Cerrar turno';

  @override
  String get cashBlindHint =>
      'Cuenta el efectivo del cajón. El sistema muestra lo esperado después de confirmar.';

  @override
  String get cashConfirmCount => 'Confirmar conteo';

  @override
  String get cashConfirmTitle => '¿Confirmar el conteo?';

  @override
  String cashConfirmBody(String amount) {
    return 'Contaste $amount. Después de confirmar, el conteo no se puede cambiar.';
  }

  @override
  String get cashExpected => 'Esperado';

  @override
  String get cashCounted => 'Contado';

  @override
  String get cashDifference => 'Diferencia';

  @override
  String get cashFloat => 'Fondo de caja';

  @override
  String get cashFlagged =>
      'Esta diferencia queda marcada para el dueño y necesita una nota';

  @override
  String get cashSeeZ => 'Ver corte Z';

  @override
  String get cashNoteForDifference => 'Nota sobre la diferencia';

  @override
  String get cashFinishClose => 'Terminar cierre';

  @override
  String get cashPastShifts => 'Cortes anteriores';

  @override
  String cashPastShift(int number) {
    return 'Corte Z $number';
  }

  @override
  String cashCountTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get cashAmount => 'Monto';

  @override
  String get cashAmountInvalid => 'Escribe un monto válido';

  @override
  String get cashReasonRequired => 'Elige un motivo';

  @override
  String get cashNoteRequired => 'Escribe una nota';

  @override
  String get cashNote => 'Nota';

  @override
  String get cashApprovalNeeded =>
      'Sin la autorización de un gerente no se puede registrar';

  @override
  String get cashReasonChangeFund => 'Fondo de cambio';

  @override
  String get cashReasonSupplier => 'Pago a proveedor';

  @override
  String get cashReasonBankDrop => 'Depósito al banco';

  @override
  String get cashReasonOther => 'Otro';

  @override
  String zTitle(String label) {
    return 'Corte Z $label';
  }

  @override
  String zOpened(String date, String name) {
    return 'Abrió: $date, $name';
  }

  @override
  String zClosed(String date, String name) {
    return 'Cerró: $date, $name';
  }

  @override
  String get zSaleCount => 'Ventas';

  @override
  String get zGross => 'Bruto';

  @override
  String get zDiscounts => 'Descuentos';

  @override
  String get zNet => 'Neto';

  @override
  String get zTaxes => 'Impuestos, netos de devoluciones';

  @override
  String zRefunds(int count) {
    return 'Devoluciones ($count)';
  }

  @override
  String zVoids(int count) {
    return 'Cancelaciones ($count)';
  }

  @override
  String get zPrepaid => 'Anticipos cobrados';

  @override
  String get zCashIn => 'Entradas de efectivo';

  @override
  String get zCashOut => 'Salidas de efectivo';

  @override
  String zNote(String note) {
    return 'Nota: $note';
  }

  @override
  String get printAction => 'Imprimir';

  @override
  String get printReprint => 'Reimprimir';

  @override
  String get printFailed => 'No se pudo imprimir. Revisa la impresora.';

  @override
  String get printerTitle => 'Impresora';

  @override
  String get printerHost => 'Dirección IP';

  @override
  String get printerPort => 'Puerto';

  @override
  String get printerTest => 'Imprimir prueba';

  @override
  String get printerTestOk => 'Prueba enviada';

  @override
  String get printerTestPage => 'Prueba de impresora';

  @override
  String get saleNoShift => 'Abre un turno para vender';

  @override
  String get saleOpenShift => 'Ir a Caja';

  @override
  String get navShifts => 'Turnos';

  @override
  String get shiftsFlaggedOnly => 'Solo diferencias';

  @override
  String get shiftsEmpty => 'No hay turnos con estos filtros';

  @override
  String get shiftsForbidden =>
      'No tienes permiso para ver los turnos de esta sucursal';

  @override
  String get shiftsColZ => 'Corte';

  @override
  String get shiftsColOpened => 'Abierto';

  @override
  String get shiftsColCashier => 'Abrió';

  @override
  String get shiftsOpenStatus => 'Abierto';

  @override
  String get shiftsFlagged => 'Diferencia marcada';

  @override
  String get shiftsMovements => 'Movimientos de efectivo';

  @override
  String get shiftsNotes => 'Notas';

  @override
  String get shiftsAddNote => 'Agregar nota';

  @override
  String get shiftsNoteHint => 'Corrección o comentario. El conteo no cambia.';

  @override
  String get shiftsLoadMore => 'Cargar más';

  @override
  String get shiftsAllDates => 'Todas las fechas';

  @override
  String get auditSaleDiscountOverLimit => 'Descuento sobre el límite';

  @override
  String get auditSaleRefunded => 'Devolución';

  @override
  String get auditSaleVoided => 'Venta cancelada';

  @override
  String get auditSaleTicketDiscarded => 'Ticket descartado';

  @override
  String get auditCashShiftOpened => 'Turno abierto';

  @override
  String get auditCashMovement => 'Movimiento de efectivo';

  @override
  String get auditCashShiftClosed => 'Turno cerrado';

  @override
  String get auditCashVarianceFlagged => 'Diferencia de caja marcada';

  @override
  String get auditCashDrawerOpened => 'Cajón abierto sin venta';

  @override
  String get auditCashNoteAdded => 'Nota en turno';
}
