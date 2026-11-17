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

  CitizenTip copyWith({
    String? status,
    String? claimantName,
    String? claimantPhone,
    String? claimantEmail,
    String? relationshipToMissing,
    String? missingPersonName,
    String? missingPersonGd,
    String? thanaFiled,
    String? similarityReasons,
  }) {
    return CitizenTip(
      id: id,
      bodyReference: bodyReference,
      claimantName: claimantName ?? this.claimantName,
      claimantPhone: claimantPhone ?? this.claimantPhone,
      claimantEmail: claimantEmail ?? this.claimantEmail,
      relationshipToMissing: relationshipToMissing ?? this.relationshipToMissing,
      missingPersonName: missingPersonName ?? this.missingPersonName,
      missingPersonGd: missingPersonGd ?? this.missingPersonGd,
      thanaFiled: thanaFiled ?? this.thanaFiled,
      similarityReasons: similarityReasons ?? this.similarityReasons,
      status: status ?? this.status,
      submittedAt: submittedAt,
    );
  }
}

