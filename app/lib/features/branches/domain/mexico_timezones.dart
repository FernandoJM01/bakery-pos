import 'package:bakery_pos/l10n/app_localizations.dart';

const List<String> mexicoTimezones = [
  'America/Mexico_City',
  'America/Cancun',
  'America/Merida',
  'America/Monterrey',
  'America/Matamoros',
  'America/Chihuahua',
  'America/Ciudad_Juarez',
  'America/Ojinaga',
  'America/Mazatlan',
  'America/Bahia_Banderas',
  'America/Hermosillo',
  'America/Tijuana',
];

String formatMexicoTimezone(String iana, AppLocalizations l10n) {
  switch (iana) {
    case 'America/Mexico_City':
      return l10n.timezoneMexicoCity;
    case 'America/Cancun':
      return l10n.timezoneCancun;
    case 'America/Merida':
      return l10n.timezoneMerida;
    case 'America/Monterrey':
      return l10n.timezoneMonterrey;
    case 'America/Matamoros':
      return l10n.timezoneMatamoros;
    case 'America/Chihuahua':
      return l10n.timezoneChihuahua;
    case 'America/Ciudad_Juarez':
      return l10n.timezoneCiudadJuarez;
    case 'America/Ojinaga':
      return l10n.timezoneOjinaga;
    case 'America/Mazatlan':
      return l10n.timezoneMazatlan;
    case 'America/Bahia_Banderas':
      return l10n.timezoneBahiaBanderas;
    case 'America/Hermosillo':
      return l10n.timezoneHermosillo;
    case 'America/Tijuana':
      return l10n.timezoneTijuana;
    default:
      return iana;
  }
}
