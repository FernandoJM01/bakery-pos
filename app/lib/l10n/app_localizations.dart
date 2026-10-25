import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// Nombre de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Bakery POS'**
  String get appTitle;

  /// No description provided for @commonConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get commonAccept;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @commonLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get commonLogout;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Regresar'**
  String get commonBack;

  /// No description provided for @validationFailed.
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos.'**
  String get validationFailed;

  /// No description provided for @statusOnline.
  ///
  /// In es, this message translates to:
  /// **'En línea'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get statusOffline;

  /// No description provided for @navSales.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get navSales;

  /// No description provided for @navCash.
  ///
  /// In es, this message translates to:
  /// **'Caja'**
  String get navCash;

  /// No description provided for @navProduction.
  ///
  /// In es, this message translates to:
  /// **'Producción'**
  String get navProduction;

  /// No description provided for @navOrders.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get navOrders;

  /// No description provided for @navOven.
  ///
  /// In es, this message translates to:
  /// **'Horno'**
  String get navOven;

  /// No description provided for @navCatalog.
  ///
  /// In es, this message translates to:
  /// **'Catálogo'**
  String get navCatalog;

  /// No description provided for @navStaff.
  ///
  /// In es, this message translates to:
  /// **'Personal'**
  String get navStaff;

  /// No description provided for @navDevices.
  ///
  /// In es, this message translates to:
  /// **'Dispositivos'**
  String get navDevices;

  /// No description provided for @navBranches.
  ///
  /// In es, this message translates to:
  /// **'Sucursales'**
  String get navBranches;

  /// No description provided for @navReports.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get navReports;

  /// No description provided for @navAudit.
  ///
  /// In es, this message translates to:
  /// **'Auditoría'**
  String get navAudit;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @enrollmentTitle.
  ///
  /// In es, this message translates to:
  /// **'Inscripción de Dispositivo'**
  String get enrollmentTitle;

  /// No description provided for @enrollmentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código generado en el portal de administración'**
  String get enrollmentSubtitle;

  /// No description provided for @enrollmentCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código de inscripción'**
  String get enrollmentCodeLabel;

  /// No description provided for @enrollmentCodeHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 8 caracteres'**
  String get enrollmentCodeHint;

  /// No description provided for @enrollmentServerUrlLabel.
  ///
  /// In es, this message translates to:
  /// **'URL del servidor'**
  String get enrollmentServerUrlLabel;

  /// No description provided for @enrollmentServerUrlHint.
  ///
  /// In es, this message translates to:
  /// **'http://localhost:3000'**
  String get enrollmentServerUrlHint;

  /// No description provided for @enrollmentSubmitButton.
  ///
  /// In es, this message translates to:
  /// **'Inscribir dispositivo'**
  String get enrollmentSubmitButton;

  /// No description provided for @enrollmentSubmitting.
  ///
  /// In es, this message translates to:
  /// **'Inscribiendo...'**
  String get enrollmentSubmitting;

  /// No description provided for @enrollmentSuccess.
  ///
  /// In es, this message translates to:
  /// **'Dispositivo inscrito correctamente'**
  String get enrollmentSuccess;

  /// No description provided for @enrollmentCodeInvalid.
  ///
  /// In es, this message translates to:
  /// **'El código es inválido o ha expirado'**
  String get enrollmentCodeInvalid;

  /// No description provided for @enrollmentRateLimited.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera unos minutos e intenta de nuevo.'**
  String get enrollmentRateLimited;

  /// No description provided for @enrollmentValidationFailed.
  ///
  /// In es, this message translates to:
  /// **'Revisa el código ingresado.'**
  String get enrollmentValidationFailed;

  /// No description provided for @enrollmentNetworkError.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión con el servidor. Verifique la URL y la red.'**
  String get enrollmentNetworkError;

  /// No description provided for @enrollmentInvalidUrl.
  ///
  /// In es, this message translates to:
  /// **'Ingrese una URL válida (ej. http://192.168.1.100:3000)'**
  String get enrollmentInvalidUrl;

  /// No description provided for @enrollmentCodeRequired.
  ///
  /// In es, this message translates to:
  /// **'El código debe tener exactamente 8 caracteres'**
  String get enrollmentCodeRequired;

  /// No description provided for @loginSelectStaff.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu usuario'**
  String get loginSelectStaff;

  /// No description provided for @loginEnterPin.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu PIN'**
  String get loginEnterPin;

  /// No description provided for @loginPinHint.
  ///
  /// In es, this message translates to:
  /// **'PIN de 4 a 6 dígitos'**
  String get loginPinHint;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @loginInvalidPin.
  ///
  /// In es, this message translates to:
  /// **'PIN incorrecto'**
  String get loginInvalidPin;

  /// No description provided for @loginLocked.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos fallidos. Bloqueado temporalmente.'**
  String get loginLocked;

  /// Mensaje de bloqueo temporal con hora
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Bloqueado hasta las {time}.'**
  String loginLockedUntil(String time);

  /// No description provided for @loginStaffNotAllowed.
  ///
  /// In es, this message translates to:
  /// **'Usuario no autorizado en esta sucursal o inactivo'**
  String get loginStaffNotAllowed;

  /// No description provided for @loginOfflineSession.
  ///
  /// In es, this message translates to:
  /// **'Sesión sin conexión'**
  String get loginOfflineSession;

  /// No description provided for @loginNoStaff.
  ///
  /// In es, this message translates to:
  /// **'No hay personal disponible. Sincroniza el dispositivo.'**
  String get loginNoStaff;

  /// No description provided for @loginSyncSuccess.
  ///
  /// In es, this message translates to:
  /// **'Personal sincronizado correctamente'**
  String get loginSyncSuccess;

  /// No description provided for @loginSyncFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al sincronizar personal con el servidor'**
  String get loginSyncFailed;

  /// No description provided for @backofficeLoginTitle.
  ///
  /// In es, this message translates to:
  /// **'Acceso a Administración'**
  String get backofficeLoginTitle;

  /// No description provided for @backofficeEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get backofficeEmailLabel;

  /// No description provided for @backofficePasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get backofficePasswordLabel;

  /// No description provided for @backofficeLoginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get backofficeLoginButton;

  /// No description provided for @backofficeInvalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Credenciales inválidas'**
  String get backofficeInvalidCredentials;

  /// Mensaje de bloqueo temporal en back office
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Bloqueado hasta las {time}.'**
  String backofficeLockedUntil(String time);

  /// No description provided for @backofficeTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel de Administración'**
  String get backofficeTitle;

  /// No description provided for @backofficeNoPermissions.
  ///
  /// In es, this message translates to:
  /// **'No tiene permisos para acceder a ninguna sección'**
  String get backofficeNoPermissions;

  /// No description provided for @branchesTitle.
  ///
  /// In es, this message translates to:
  /// **'Sucursales'**
  String get branchesTitle;

  /// No description provided for @branchesNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva sucursal'**
  String get branchesNew;

  /// No description provided for @branchesEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar sucursal'**
  String get branchesEdit;

  /// No description provided for @branchesCode.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get branchesCode;

  /// No description provided for @branchesName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get branchesName;

  /// No description provided for @branchesAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get branchesAddress;

  /// No description provided for @branchesTimezone.
  ///
  /// In es, this message translates to:
  /// **'Zona horaria'**
  String get branchesTimezone;

  /// No description provided for @branchesStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get branchesStatus;

  /// No description provided for @branchesActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get branchesActive;

  /// No description provided for @branchesInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactiva'**
  String get branchesInactive;

  /// No description provided for @branchesCodeImmutable.
  ///
  /// In es, this message translates to:
  /// **'El código no se puede modificar'**
  String get branchesCodeImmutable;

  /// No description provided for @branchesCodeInvalid.
  ///
  /// In es, this message translates to:
  /// **'El código debe tener entre 2 y 10 caracteres alfanuméricos en mayúsculas'**
  String get branchesCodeInvalid;

  /// No description provided for @branchesNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get branchesNameRequired;

  /// No description provided for @branchesNameInvalid.
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener entre 1 y 120 caracteres'**
  String get branchesNameInvalid;

  /// No description provided for @branchesTimezoneRequired.
  ///
  /// In es, this message translates to:
  /// **'La zona horaria es obligatoria'**
  String get branchesTimezoneRequired;

  /// No description provided for @branchesEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay sucursales registradas'**
  String get branchesEmpty;

  /// No description provided for @branchesCreateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Sucursal creada exitosamente'**
  String get branchesCreateSuccess;

  /// No description provided for @branchesUpdateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Sucursal actualizada exitosamente'**
  String get branchesUpdateSuccess;

  /// No description provided for @branchesCodeConflict.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una sucursal con ese código'**
  String get branchesCodeConflict;

  /// No description provided for @branchesErrorLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar las sucursales'**
  String get branchesErrorLoading;

  /// No description provided for @branchesSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando...'**
  String get branchesSaving;

  /// No description provided for @timezoneMexicoCity.
  ///
  /// In es, this message translates to:
  /// **'Centro (Ciudad de México)'**
  String get timezoneMexicoCity;

  /// No description provided for @timezoneCancun.
  ///
  /// In es, this message translates to:
  /// **'Sureste (Cancún)'**
  String get timezoneCancun;

  /// No description provided for @timezoneMerida.
  ///
  /// In es, this message translates to:
  /// **'Centro (Mérida)'**
  String get timezoneMerida;

  /// No description provided for @timezoneMonterrey.
  ///
  /// In es, this message translates to:
  /// **'Centro (Monterrey)'**
  String get timezoneMonterrey;

  /// No description provided for @timezoneMatamoros.
  ///
  /// In es, this message translates to:
  /// **'Frontera Norte (Matamoros)'**
  String get timezoneMatamoros;

  /// No description provided for @timezoneChihuahua.
  ///
  /// In es, this message translates to:
  /// **'Montaña (Chihuahua)'**
  String get timezoneChihuahua;

  /// No description provided for @timezoneCiudadJuarez.
  ///
  /// In es, this message translates to:
  /// **'Frontera Norte (Ciudad Juárez)'**
  String get timezoneCiudadJuarez;

  /// No description provided for @timezoneOjinaga.
  ///
  /// In es, this message translates to:
  /// **'Frontera Norte (Ojinaga)'**
  String get timezoneOjinaga;

  /// No description provided for @timezoneMazatlan.
  ///
  /// In es, this message translates to:
  /// **'Pacífico (Mazatlán)'**
  String get timezoneMazatlan;

  /// No description provided for @timezoneBahiaBanderas.
  ///
  /// In es, this message translates to:
  /// **'Centro (Bahía de Banderas)'**
  String get timezoneBahiaBanderas;

  /// No description provided for @timezoneHermosillo.
  ///
  /// In es, this message translates to:
  /// **'Pacífico (Hermosillo)'**
  String get timezoneHermosillo;

  /// No description provided for @timezoneTijuana.
  ///
  /// In es, this message translates to:
  /// **'Noroeste (Tijuana)'**
  String get timezoneTijuana;

  /// No description provided for @approvalTitle.
  ///
  /// In es, this message translates to:
  /// **'Aprobación de Gerente'**
  String get approvalTitle;

  /// No description provided for @approvalPinPrompt.
  ///
  /// In es, this message translates to:
  /// **'Ingrese PIN de gerente para aprobar esta acción'**
  String get approvalPinPrompt;

  /// No description provided for @approvalGranted.
  ///
  /// In es, this message translates to:
  /// **'Acción aprobada'**
  String get approvalGranted;

  /// No description provided for @approvalDenied.
  ///
  /// In es, this message translates to:
  /// **'Aprobación denegada'**
  String get approvalDenied;

  /// No description provided for @approvalSelectApprover.
  ///
  /// In es, this message translates to:
  /// **'Selecciona quién autoriza'**
  String get approvalSelectApprover;

  /// No description provided for @approvalNoApprovers.
  ///
  /// In es, this message translates to:
  /// **'No hay personal con permiso para autorizar esta acción'**
  String get approvalNoApprovers;

  /// No description provided for @approvalPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'El usuario no tiene permiso para autorizar esta acción'**
  String get approvalPermissionDenied;

  /// No description provided for @approvalInvalidPin.
  ///
  /// In es, this message translates to:
  /// **'PIN incorrecto'**
  String get approvalInvalidPin;

  /// No description provided for @approvalLocked.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Bloqueado temporalmente.'**
  String get approvalLocked;

  /// No description provided for @debugOpenDrawerNoSale.
  ///
  /// In es, this message translates to:
  /// **'Abrir cajón sin venta (demo)'**
  String get debugOpenDrawerNoSale;

  /// No description provided for @deviceRevokedTitle.
  ///
  /// In es, this message translates to:
  /// **'Dispositivo revocado'**
  String get deviceRevokedTitle;

  /// No description provided for @deviceRevokedMessage.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo ha sido revocado. Los datos locales serán eliminados.'**
  String get deviceRevokedMessage;

  /// No description provided for @placeholderSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Sección en desarrollo'**
  String get placeholderSectionTitle;

  /// No description provided for @placeholderSectionMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta funcionalidad estará disponible en un próximo hito.'**
  String get placeholderSectionMessage;

  /// No description provided for @commonRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get commonRefresh;

  /// No description provided for @adminConflict.
  ///
  /// In es, this message translates to:
  /// **'Ya existe un registro con esos datos.'**
  String get adminConflict;

  /// No description provided for @adminNotFound.
  ///
  /// In es, this message translates to:
  /// **'Ya no existe. Actualiza la lista.'**
  String get adminNotFound;

  /// No description provided for @adminPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'No tienes permiso para hacer esto.'**
  String get adminPermissionDenied;

  /// No description provided for @allBranches.
  ///
  /// In es, this message translates to:
  /// **'Todas las sucursales'**
  String get allBranches;

  /// No description provided for @allRoles.
  ///
  /// In es, this message translates to:
  /// **'Todos los puestos'**
  String get allRoles;

  /// No description provided for @roleOwner.
  ///
  /// In es, this message translates to:
  /// **'Dueño'**
  String get roleOwner;

  /// No description provided for @roleBranchManager.
  ///
  /// In es, this message translates to:
  /// **'Gerente de sucursal'**
  String get roleBranchManager;

  /// No description provided for @roleCashier.
  ///
  /// In es, this message translates to:
  /// **'Cajero'**
  String get roleCashier;

  /// No description provided for @roleBaker.
  ///
  /// In es, this message translates to:
  /// **'Panadero'**
  String get roleBaker;

  /// No description provided for @staffTitle.
  ///
  /// In es, this message translates to:
  /// **'Personal'**
  String get staffTitle;

  /// No description provided for @staffNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva persona'**
  String get staffNew;

  /// No description provided for @staffEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar persona'**
  String get staffEdit;

  /// No description provided for @staffFullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get staffFullName;

  /// No description provided for @staffFullNameInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre completo (máximo 120 caracteres)'**
  String get staffFullNameInvalid;

  /// No description provided for @staffDisplayName.
  ///
  /// In es, this message translates to:
  /// **'Nombre en la caja'**
  String get staffDisplayName;

  /// No description provided for @staffDisplayNameHelp.
  ///
  /// In es, this message translates to:
  /// **'Así aparece en la pantalla de PIN'**
  String get staffDisplayNameHelp;

  /// No description provided for @staffDisplayNameInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre corto (máximo 30 caracteres)'**
  String get staffDisplayNameInvalid;

  /// No description provided for @staffRole.
  ///
  /// In es, this message translates to:
  /// **'Puesto'**
  String get staffRole;

  /// No description provided for @staffBranch.
  ///
  /// In es, this message translates to:
  /// **'Sucursal'**
  String get staffBranch;

  /// No description provided for @staffBranches.
  ///
  /// In es, this message translates to:
  /// **'Sucursales'**
  String get staffBranches;

  /// No description provided for @staffBranchesRequired.
  ///
  /// In es, this message translates to:
  /// **'Elige al menos una sucursal'**
  String get staffBranchesRequired;

  /// No description provided for @staffEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get staffEmail;

  /// No description provided for @staffEmailOptional.
  ///
  /// In es, this message translates to:
  /// **'Correo (opcional, para entrar a la administración)'**
  String get staffEmailOptional;

  /// No description provided for @staffEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'El correo es obligatorio para entrar a la administración'**
  String get staffEmailRequired;

  /// No description provided for @staffEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe un correo válido'**
  String get staffEmailInvalid;

  /// No description provided for @staffPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get staffPassword;

  /// No description provided for @staffNewPasswordOptional.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña (déjala vacía para no cambiarla)'**
  String get staffNewPasswordOptional;

  /// No description provided for @staffPasswordHelp.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 10 caracteres. Cambiarla cierra sus sesiones abiertas.'**
  String get staffPasswordHelp;

  /// No description provided for @staffPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'El dueño necesita contraseña'**
  String get staffPasswordRequired;

  /// No description provided for @staffPasswordTooShort.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 10 caracteres'**
  String get staffPasswordTooShort;

  /// No description provided for @staffPin.
  ///
  /// In es, this message translates to:
  /// **'PIN (4 a 6 dígitos)'**
  String get staffPin;

  /// No description provided for @staffPinConfirm.
  ///
  /// In es, this message translates to:
  /// **'Repite el PIN'**
  String get staffPinConfirm;

  /// No description provided for @staffPinInvalid.
  ///
  /// In es, this message translates to:
  /// **'El PIN debe tener de 4 a 6 dígitos'**
  String get staffPinInvalid;

  /// No description provided for @staffPinMismatch.
  ///
  /// In es, this message translates to:
  /// **'Los PIN no coinciden'**
  String get staffPinMismatch;

  /// No description provided for @staffShowInactive.
  ///
  /// In es, this message translates to:
  /// **'Mostrar dados de baja'**
  String get staffShowInactive;

  /// No description provided for @staffActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get staffActive;

  /// No description provided for @staffInactive.
  ///
  /// In es, this message translates to:
  /// **'Dado de baja'**
  String get staffInactive;

  /// No description provided for @staffLocked.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado'**
  String get staffLocked;

  /// No description provided for @staffEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay personal con estos filtros'**
  String get staffEmpty;

  /// No description provided for @staffErrorLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar el personal'**
  String get staffErrorLoading;

  /// No description provided for @staffCreated.
  ///
  /// In es, this message translates to:
  /// **'Persona agregada'**
  String get staffCreated;

  /// No description provided for @staffUpdated.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get staffUpdated;

  /// No description provided for @staffResetPin.
  ///
  /// In es, this message translates to:
  /// **'Cambiar PIN'**
  String get staffResetPin;

  /// No description provided for @staffResetPinMessage.
  ///
  /// In es, this message translates to:
  /// **'El nuevo PIN funciona de inmediato. Se desbloquea la cuenta y se cierran sus sesiones abiertas.'**
  String get staffResetPinMessage;

  /// No description provided for @staffPinChanged.
  ///
  /// In es, this message translates to:
  /// **'PIN cambiado'**
  String get staffPinChanged;

  /// No description provided for @staffDeactivate.
  ///
  /// In es, this message translates to:
  /// **'Dar de baja'**
  String get staffDeactivate;

  /// No description provided for @staffReactivate.
  ///
  /// In es, this message translates to:
  /// **'Reactivar'**
  String get staffReactivate;

  /// No description provided for @staffDeactivateMessage.
  ///
  /// In es, this message translates to:
  /// **'Ya no podrá entrar a ninguna caja ni a la administración y se cierran sus sesiones abiertas. Su historial se conserva y puedes reactivarla después.'**
  String get staffDeactivateMessage;

  /// No description provided for @staffDeactivated.
  ///
  /// In es, this message translates to:
  /// **'Persona dada de baja'**
  String get staffDeactivated;

  /// No description provided for @staffReactivated.
  ///
  /// In es, this message translates to:
  /// **'Persona reactivada'**
  String get staffReactivated;

  /// No description provided for @staffEmailConflict.
  ///
  /// In es, this message translates to:
  /// **'Ese correo ya lo usa otra persona'**
  String get staffEmailConflict;

  /// No description provided for @staffLastOwner.
  ///
  /// In es, this message translates to:
  /// **'No se puede: debe quedar al menos un dueño activo'**
  String get staffLastOwner;

  /// No description provided for @devicesTitle.
  ///
  /// In es, this message translates to:
  /// **'Dispositivos'**
  String get devicesTitle;

  /// No description provided for @deviceNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo dispositivo'**
  String get deviceNew;

  /// No description provided for @deviceName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get deviceName;

  /// No description provided for @deviceNameHelp.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: Caja 1, Mostrador'**
  String get deviceNameHelp;

  /// No description provided for @deviceNameInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre (máximo 60 caracteres)'**
  String get deviceNameInvalid;

  /// No description provided for @deviceType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get deviceType;

  /// No description provided for @deviceTypeTill.
  ///
  /// In es, this message translates to:
  /// **'Caja'**
  String get deviceTypeTill;

  /// No description provided for @deviceTypeProduction.
  ///
  /// In es, this message translates to:
  /// **'Producción'**
  String get deviceTypeProduction;

  /// No description provided for @deviceLastSeen.
  ///
  /// In es, this message translates to:
  /// **'Última conexión'**
  String get deviceLastSeen;

  /// No description provided for @deviceShowRevoked.
  ///
  /// In es, this message translates to:
  /// **'Mostrar revocados'**
  String get deviceShowRevoked;

  /// No description provided for @deviceStatusActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get deviceStatusActive;

  /// No description provided for @deviceStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Esperando código'**
  String get deviceStatusPending;

  /// No description provided for @deviceStatusRevoked.
  ///
  /// In es, this message translates to:
  /// **'Revocado'**
  String get deviceStatusRevoked;

  /// No description provided for @deviceBranchRequired.
  ///
  /// In es, this message translates to:
  /// **'Elige la sucursal'**
  String get deviceBranchRequired;

  /// No description provided for @deviceBranchInactive.
  ///
  /// In es, this message translates to:
  /// **'No se pudo registrar: revisa que la sucursal esté activa.'**
  String get deviceBranchInactive;

  /// No description provided for @deviceCreateAndGetCode.
  ///
  /// In es, this message translates to:
  /// **'Registrar y ver código'**
  String get deviceCreateAndGetCode;

  /// No description provided for @deviceNewCode.
  ///
  /// In es, this message translates to:
  /// **'Nuevo código'**
  String get deviceNewCode;

  /// No description provided for @deviceNewCodeMessage.
  ///
  /// In es, this message translates to:
  /// **'El código anterior deja de funcionar.'**
  String get deviceNewCodeMessage;

  /// No description provided for @deviceRevoke.
  ///
  /// In es, this message translates to:
  /// **'Revocar'**
  String get deviceRevoke;

  /// No description provided for @deviceRevokeMessage.
  ///
  /// In es, this message translates to:
  /// **'El dispositivo se desconecta de inmediato y ya no podrá usarse. Para volver a usarlo hay que registrarlo como nuevo.'**
  String get deviceRevokeMessage;

  /// No description provided for @deviceRevoked.
  ///
  /// In es, this message translates to:
  /// **'Dispositivo revocado'**
  String get deviceRevoked;

  /// No description provided for @deviceCopyCode.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get deviceCopyCode;

  /// No description provided for @deviceCodeDone.
  ///
  /// In es, this message translates to:
  /// **'Ya lo anoté'**
  String get deviceCodeDone;

  /// No description provided for @devicesEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay dispositivos con estos filtros'**
  String get devicesEmpty;

  /// No description provided for @devicesErrorLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar los dispositivos'**
  String get devicesErrorLoading;

  /// No description provided for @auditTitle.
  ///
  /// In es, this message translates to:
  /// **'Auditoría'**
  String get auditTitle;

  /// No description provided for @auditAction.
  ///
  /// In es, this message translates to:
  /// **'Acción'**
  String get auditAction;

  /// No description provided for @auditAllActions.
  ///
  /// In es, this message translates to:
  /// **'Todas las acciones'**
  String get auditAllActions;

  /// No description provided for @auditPerson.
  ///
  /// In es, this message translates to:
  /// **'Persona'**
  String get auditPerson;

  /// No description provided for @auditAllPeople.
  ///
  /// In es, this message translates to:
  /// **'Todas las personas'**
  String get auditAllPeople;

  /// No description provided for @auditAnyDate.
  ///
  /// In es, this message translates to:
  /// **'Cualquier fecha'**
  String get auditAnyDate;

  /// No description provided for @auditClearDates.
  ///
  /// In es, this message translates to:
  /// **'Quitar fechas'**
  String get auditClearDates;

  /// No description provided for @auditEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay movimientos con estos filtros'**
  String get auditEmpty;

  /// No description provided for @auditLoadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get auditLoadMore;

  /// No description provided for @auditSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get auditSystem;

  /// No description provided for @auditUnknownPerson.
  ///
  /// In es, this message translates to:
  /// **'Persona desconocida'**
  String get auditUnknownPerson;

  /// No description provided for @auditLoginSuccess.
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión'**
  String get auditLoginSuccess;

  /// No description provided for @auditLoginFailure.
  ///
  /// In es, this message translates to:
  /// **'Intento fallido de inicio de sesión'**
  String get auditLoginFailure;

  /// No description provided for @auditLocked.
  ///
  /// In es, this message translates to:
  /// **'Cuenta bloqueada por intentos'**
  String get auditLocked;

  /// No description provided for @auditLogout.
  ///
  /// In es, this message translates to:
  /// **'Cierre de sesión'**
  String get auditLogout;

  /// No description provided for @auditApprovalGranted.
  ///
  /// In es, this message translates to:
  /// **'Autorización de gerente concedida'**
  String get auditApprovalGranted;

  /// No description provided for @auditApprovalDenied.
  ///
  /// In es, this message translates to:
  /// **'Autorización de gerente rechazada'**
  String get auditApprovalDenied;

  /// No description provided for @auditStaffCreated.
  ///
  /// In es, this message translates to:
  /// **'Persona agregada'**
  String get auditStaffCreated;

  /// No description provided for @auditStaffUpdated.
  ///
  /// In es, this message translates to:
  /// **'Persona modificada'**
  String get auditStaffUpdated;

  /// No description provided for @auditStaffDeactivated.
  ///
  /// In es, this message translates to:
  /// **'Persona dada de baja'**
  String get auditStaffDeactivated;

  /// No description provided for @auditStaffPinChanged.
  ///
  /// In es, this message translates to:
  /// **'PIN cambiado'**
  String get auditStaffPinChanged;

  /// No description provided for @auditDeviceCreated.
  ///
  /// In es, this message translates to:
  /// **'Dispositivo registrado'**
  String get auditDeviceCreated;

  /// No description provided for @auditDeviceActivated.
  ///
  /// In es, this message translates to:
  /// **'Dispositivo activado'**
  String get auditDeviceActivated;

  /// No description provided for @auditDeviceRevoked.
  ///
  /// In es, this message translates to:
  /// **'Dispositivo revocado'**
  String get auditDeviceRevoked;

  /// No description provided for @auditBranchCreated.
  ///
  /// In es, this message translates to:
  /// **'Sucursal creada'**
  String get auditBranchCreated;

  /// No description provided for @auditBranchUpdated.
  ///
  /// In es, this message translates to:
  /// **'Sucursal modificada'**
  String get auditBranchUpdated;

  /// No description provided for @staffDeactivateTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Dar de baja a {name}?'**
  String staffDeactivateTitle(String name);

  /// No description provided for @staffResetPinTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar el PIN de {name}'**
  String staffResetPinTitle(String name);

  /// No description provided for @deviceNewCodeTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Nuevo código para {name}?'**
  String deviceNewCodeTitle(String name);

  /// No description provided for @deviceRevokeTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Revocar {name}?'**
  String deviceRevokeTitle(String name);

  /// No description provided for @deviceCodeTitle.
  ///
  /// In es, this message translates to:
  /// **'Código para {name}'**
  String deviceCodeTitle(String name);

  /// No description provided for @deviceCodeInstructions.
  ///
  /// In es, this message translates to:
  /// **'Escribe este código en la tableta al abrir la app. Vence a las {time} y solo se muestra esta vez.'**
  String deviceCodeInstructions(String time);

  /// No description provided for @auditApprovedBy.
  ///
  /// In es, this message translates to:
  /// **'autorizó {name}'**
  String auditApprovedBy(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
