class OfficialAccessRequest {
  final String id;
  final String requestCode; // e.g. REQ-2026-0042
  final String officerName;
  final String officerRank; // SI, Inspector, ASP, OC
  final String bpNumber; // Bangladesh Police ID
  final String postingUnit; // e.g. Ramna Model Thana, DMP
  final String contactPhone;
  final String officialEmail;
  final String targetCaseReference; // e.g. CIB-UDB-2026-001 or ALL
  final String investigationGdFir; // GD No. 425/2026
  final String reasonForAccess;
  final String status; // 'pending', 'approved', 'rejected'
  final String requestedAt;
  final String? reviewedBy;
  final String? reviewNotes;
  final String? accessToken;
  final String? tokenExpiresAt;

  const OfficialAccessRequest({
    required this.id,
    required this.requestCode,
    required this.officerName,
    required this.officerRank,
    required this.bpNumber,
    required this.postingUnit,
    required this.contactPhone,
    required this.officialEmail,
    required this.targetCaseReference,
    required this.investigationGdFir,
    required this.reasonForAccess,
    this.status = 'pending',
    required this.requestedAt,
    this.reviewedBy,
    this.reviewNotes,
    this.accessToken,
    this.tokenExpiresAt,
  });

  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';

  OfficialAccessRequest copyWith({
    String? status,
    String? reviewedBy,
    String? reviewNotes,
    String? accessToken,
    String? tokenExpiresAt,
  }) {
    return OfficialAccessRequest(
      id: id,
      requestCode: requestCode,
      officerName: officerName,
      officerRank: officerRank,
      bpNumber: bpNumber,
      postingUnit: postingUnit,
      contactPhone: contactPhone,
      officialEmail: officialEmail,
      targetCaseReference: targetCaseReference,
      investigationGdFir: investigationGdFir,
      reasonForAccess: reasonForAccess,
      status: status ?? this.status,
      requestedAt: requestedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      accessToken: accessToken ?? this.accessToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    );
  }
}

