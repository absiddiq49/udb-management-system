class AppConstants {
  static const String appName = 'CID Unidentified Dead Body Management System';
  static const String appAbbr = 'CID UDB-MS';
  static const String agencyName = 'Criminal Investigation Department (CID)';
  static const String ministry = 'Bangladesh Police • Ministry of Home Affairs';
  
  static const String emergencyPolice = '999';
  static const String cidHelpline = '+880 2 48312000';
  static const String cidEmail = 'cib@cid.police.gov.bd';

  static const List<String> divisions = [
    'Dhaka',
    'Chattogram',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ];

  static const List<String> genders = [
    'Male',
    'Female',
    'Transgender',
    'Unknown',
  ];

  static const List<String> ageGroups = [
    '0-12 (Child)',
    '13-17 (Adolescent)',
    '18-25 (Young Adult)',
    '26-35 (Adult)',
    '36-50 (Middle Aged)',
    '51+ (Elderly)',
  ];

  static const List<String> bodyConditions = [
    'Recoverable visual features',
    'Decomposed',
    'Advanced decomposition',
    'Skeletal remains',
    'Charred / Burned',
    'Mutilated',
    'Dismembered',
    'Floater / Water immersed',
  ];

  static const List<String> inputTeams = [
    'Central Intelligence Bureau (CIB)',
    'Crime Scene Investigation (CSI) Team',
    'Forensic DNA Laboratory Desk',
    'Fingerprint & AFIS Bureau',
    'District Police CID Liaison',
    'Metropolitan Police Special Unit',
  ];

  static const List<String> caseStatuses = [
    'Unidentified - new entry',
    'Unidentified - active matching',
    'Unidentified - under verification',
    'Unidentified - DNA profile stored',
    'Pending forensic confirmation',
    'Probable match found',
    'Identified and closed',
  ];
}

