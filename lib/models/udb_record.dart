import 'forensic_photo.dart';
import 'forensic_document.dart';

class CaseNoteEntry {
  final String id;
  final String authorName;
  final String authorBp;
  final String category; // 'Forensic Lab', 'Thana Lead', 'DNA Match', 'General Inquest', 'Relative Inquiry'
  final String content;
  final String timestamp;

  const CaseNoteEntry({
    required this.id,
    required this.authorName,
    required this.authorBp,
    required this.category,
    required this.content,
    required this.timestamp,
  });
}

class UdbRecord {
  final String id;
  final String referenceNo; // e.g. CIB-UDB-2026-001
  final String source;
  final String inputTeam;

  // Recovery Particulars
  final String dateFound;
  final String timeFound;
  final String division;
  final String district;
  final String thana;
  final String placeFound;
  final String locationFound;
  final String gdCaseReference;
  final String recoveryOfficerUnit;

  // Physical & Anthropological Descriptors
  final String gender;
  final int estimatedAge;
  final String ageGroup;
  final int heightCm;
  final int weightKg;
  final String bodyCondition;
  final String estimatedDeathTime;
  final String complexion;
  final String hair;
  final String facialHair;

  // Marks, Scars, Tattoos & Dental
  final String identificationMarks;
  final String scars;
  final String tattoos;
  final String birthmarks;
  final String dentalCharacteristics;
  final String otherCharacteristics;

  // Clothing & Effects
  final String clothing;
  final String personalBelongings;

  // Forensic Identifiers
  final String fingerprintAvailability;
  final String dnaProfileAvailability;
  final String postmortemReference;
  final String linkedForensicRecord;

  // Narrative & Officer Notes
  final String description;
  final String remarks;

  // Status & Media
  final String status;
  final bool isPublicPublished;
  final List<ForensicPhoto> photos;
  final List<ForensicDocument> documents;
  final List<CaseNoteEntry> caseNotes;

  const UdbRecord({
    required this.id,
    required this.referenceNo,
    this.source = 'Central Intelligence Bureau (CIB)',
    required this.inputTeam,
    required this.dateFound,
    this.timeFound = '10:30 AM',
    required this.division,
    required this.district,
    required this.thana,
    required this.placeFound,
    required this.locationFound,
    required this.gdCaseReference,
    required this.recoveryOfficerUnit,
    required this.gender,
    required this.estimatedAge,
    required this.ageGroup,
    required this.heightCm,
    required this.weightKg,
    this.bodyCondition = 'Recoverable visual features',
    this.estimatedDeathTime = '24-48 hours before recovery',
    this.complexion = 'Wheatish',
    this.hair = 'Black short',
    this.facialHair = 'Clean shaven',
    required this.identificationMarks,
    this.scars = 'None documented',
    this.tattoos = 'None visible',
    this.birthmarks = 'None reported',
    this.dentalCharacteristics = 'Natural teeth intact',
    this.otherCharacteristics = '',
    required this.clothing,
    this.personalBelongings = 'None',
    required this.fingerprintAvailability,
    required this.dnaProfileAvailability,
    required this.postmortemReference,
    this.linkedForensicRecord = 'CID National Forensic DNA Profiling Lab',
    required this.description,
    this.remarks = '',
    required this.status,
    this.isPublicPublished = true,
    this.photos = const [],
    this.documents = const [],
    this.caseNotes = const [],
  });

  bool get hasDna =>
      dnaProfileAvailability.toLowerCase().contains('available') &&
      !dnaProfileAvailability.toLowerCase().contains('unavailable');

  bool get hasFingerprint =>
      !fingerprintAvailability.toLowerCase().contains('unavailable');

  ForensicPhoto? get primaryPhoto =>
      photos.isNotEmpty ? photos.firstWhere((p) => p.isPrimary, orElse: () => photos.first) : null;

  UdbRecord copyWith({
    String? status,
    String? remarks,
    List<ForensicPhoto>? photos,
    List<ForensicDocument>? documents,
    List<CaseNoteEntry>? caseNotes,
  }) {
    return UdbRecord(
      id: id,
      referenceNo: referenceNo,
      source: source,
      inputTeam: inputTeam,
      dateFound: dateFound,
      timeFound: timeFound,
      division: division,
      district: district,
      thana: thana,
      placeFound: placeFound,
      locationFound: locationFound,
      gdCaseReference: gdCaseReference,
      recoveryOfficerUnit: recoveryOfficerUnit,
      gender: gender,
      estimatedAge: estimatedAge,
      ageGroup: ageGroup,
      heightCm: heightCm,
      weightKg: weightKg,
      bodyCondition: bodyCondition,
      estimatedDeathTime: estimatedDeathTime,
      complexion: complexion,
      hair: hair,
      facialHair: facialHair,
      identificationMarks: identificationMarks,
      scars: scars,
      tattoos: tattoos,
      birthmarks: birthmarks,
      dentalCharacteristics: dentalCharacteristics,
      otherCharacteristics: otherCharacteristics,
      clothing: clothing,
      personalBelongings: personalBelongings,
      fingerprintAvailability: fingerprintAvailability,
      dnaProfileAvailability: dnaProfileAvailability,
      postmortemReference: postmortemReference,
      linkedForensicRecord: linkedForensicRecord,
      description: description,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      isPublicPublished: isPublicPublished,
      photos: photos ?? this.photos,
      documents: documents ?? this.documents,
      caseNotes: caseNotes ?? this.caseNotes,
    );
  }
}

