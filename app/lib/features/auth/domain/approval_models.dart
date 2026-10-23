sealed class ApprovalResult {
  const ApprovalResult();
}

class OnlineApprovalResult extends ApprovalResult {
  const OnlineApprovalResult({
    required this.approvalToken,
    required this.expiresAt,
    required this.approverStaffId,
    required this.action,
  });

  final String approvalToken;
  final DateTime expiresAt;
  final String approverStaffId;
  final String action;
}

class OfflineApprovalResult extends ApprovalResult {
  const OfflineApprovalResult({
    required this.id,
    required this.approverStaffId,
    required this.requesterStaffId,
    required this.action,
    this.reference,
    required this.createdAt,
    this.syncedAt,
  });

  final String id;
  final String approverStaffId;
  final String requesterStaffId;
  final String action;
  final String? reference;
  final DateTime createdAt;
  final DateTime? syncedAt;
}
