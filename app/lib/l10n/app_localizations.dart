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
