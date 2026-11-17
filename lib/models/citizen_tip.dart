class CitizenTip {
  final String id;
  final String bodyReference; // CIB-UDB-2026-001
  final String claimantName;
  final String claimantPhone;
  final String? claimantEmail;
  final String relationshipToMissing;
  final String missingPersonName;
  final String missingPersonGd;
  final String thanaFiled;
  final String similarityReasons;
  final String status; // 'NEW_LEAD', 'UNDER_INVESTIGATION', 'VERIFIED_MATCH', 'REJECTED'
  final String submittedAt;

  const CitizenTip({
    required this.id,
    required this.bodyReference,
    required this.claimantName,
    required this.claimantPhone,
    this.claimantEmail,
    required this.relationshipToMissing,
    required this.missingPersonName,
    required this.missingPersonGd,
    required this.thanaFiled,
    required this.similarityReasons,
    this.status = 'NEW_LEAD',
    required this.submittedAt,
  });
}

