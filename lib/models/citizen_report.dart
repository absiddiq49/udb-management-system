class CitizenReport {
  final String id;
  final String reportReference; // CIT-REP-2026-0001
  final String reporterName;
  final String reporterPhone;
  final String? reporterNid;
  final String division;
  final String district;
  final String thana;
  final String spotLocation;
  final String dateSpotted;
  final String timeSpotted;
  final String description;
  final String conditionDescription;
  final List<String> photoUrls;
  final String status; // 'PENDING_POLICE_DISPATCH', 'VERIFIED_UNDER_INTAKE', 'DISMISSED'
  final String submittedAt;

  const CitizenReport({
    required this.id,
    required this.reportReference,
    required this.reporterName,
    required this.reporterPhone,
    this.reporterNid,
    required this.division,
    required this.district,
    required this.thana,
    required this.spotLocation,
    required this.dateSpotted,
    required this.timeSpotted,
    required this.description,
    required this.conditionDescription,
    this.photoUrls = const [],
    this.status = 'PENDING_POLICE_DISPATCH',
    required this.submittedAt,
  });

  CitizenReport copyWith({String? status}) {
    return CitizenReport(
      id: id,
      reportReference: reportReference,
      reporterName: reporterName,
      reporterPhone: reporterPhone,
      reporterNid: reporterNid,
      division: division,
      district: district,
      thana: thana,
      spotLocation: spotLocation,
      dateSpotted: dateSpotted,
      timeSpotted: timeSpotted,
      description: description,
      conditionDescription: conditionDescription,
      photoUrls: photoUrls,
      status: status ?? this.status,
      submittedAt: submittedAt,
    );
  }
}

