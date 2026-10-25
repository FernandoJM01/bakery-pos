import 'package:bakery_pos/core/api/generated/models/role.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';

String roleLabel(Role role, AppLocalizations l10n) {
  switch (role) {
    case Role.owner:
      return l10n.roleOwner;
    case Role.branchManager:
      return l10n.roleBranchManager;
    case Role.cashier:
      return l10n.roleCashier;
    case Role.baker:
      return l10n.roleBaker;
    default:
      return role.json ?? role.name;
  }
}

final pinPattern = RegExp(r'^[0-9]{4,6}$');
final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
