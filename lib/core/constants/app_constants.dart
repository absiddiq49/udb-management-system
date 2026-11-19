class AppConstants {
  static const String appName = 'CID Unidentified Dead Body Management System';
  static const String appAbbr = 'CID UDB-MS';
  static const String agencyName = 'Criminal Investigation Department (CID)';
  static const String ministry = 'Bangladesh Police • Ministry of Home Affairs';

  /// Reviewer/demo mode. Set to false for any real deployment: it hides the
  /// pre-filled demo credentials and the demo access-pass hints.
  static const bool demoMode = true;
  
  static const String emergencyPolice = '999';
  static const String cidHelpline = '02-48311051';
  static const String cidEmail = 'cib@cid.police.gov.bd';
  static const String riverPoliceControl = '01320-169598'; // নৌ পুলিশ কন্ট্রোল রুম (নদীতে ভাসমান লাশ)
  static const String railwayPoliceControl = '01320-177598'; // রেলওয়ে পুলিশ কন্ট্রোল রুম (রেললাইনে উদ্ধারকৃত মরদেহ)
  static const String highwayPoliceControl = '01320-182598'; // হাইওয়ে পুলিশ কন্ট্রোল রুম (মহাসড়কে সড়ক দুর্ঘটনা)
  static const String nationalDnaLab = '02-48310051'; // সিআইডি জাতীয় ডিএনএ প্রোফাইলিং ল্যাবরেটরি
  static const String anjumanMufidulIslam = '02-9336611'; // আঞ্জুমান মুফিদুল ইসলাম (কাকরাইল প্রধান কার্যালয়)

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

  static const Map<String, List<String>> divisionDistricts = {
    'Dhaka': ['Dhaka', 'Gazipur', 'Narayanganj', 'Tangail', 'Faridpur', 'Manikganj', 'Munshiganj', 'Narsingdi', 'Kishoreganj', 'Gopalganj', 'Madaripur', 'Rajbari', 'Shariatpur'],
    'Chattogram': ['Chattogram', 'Cox\'s Bazar', 'Cumilla', 'Feni', 'Brahmanbaria', 'Noakhali', 'Chandpur', 'Khagrachhari', 'Rangamati', 'Bandarban', 'Lakshmipur'],
    'Rajshahi': ['Rajshahi', 'Bogura', 'Pabna', 'Sirajganj', 'Naogaon', 'Natore', 'Chapai Nawabganj', 'Joypurhat'],
    'Khulna': ['Khulna', 'Jashore', 'Kushtia', 'Satkhira', 'Bagerhat', 'Jhenaidah', 'Chuadanga', 'Meherpur', 'Magura', 'Narail'],
    'Barishal': ['Barishal', 'Patuakhali', 'Bhola', 'Pirojpur', 'Jhalokati', 'Barguna'],
    'Sylhet': ['Sylhet', 'Moulvibazar', 'Habiganj', 'Sunamganj'],
    'Rangpur': ['Rangpur', 'Dinajpur', 'Kurigram', 'Gaibandha', 'Thakurgaon', 'Nilphamari', 'Lalmonirhat', 'Panchagarh'],
    'Mymensingh': ['Mymensingh', 'Jamalpur', 'Netrokona', 'Sherpur'],
  };

  static const List<String> complexions = [
    'Fair (ফর্সা)',
    'Wheatish (উজ্জ্বল শ্যামলা)',
    'Medium / Dusky (শ্যামলা)',
    'Dark (কালো)',
  ];

  static const List<String> commonClothing = [
    'Lungi (লুঙ্গি)',
    'Shirt (শার্ট)',
    'T-Shirt / Ganji (গেঞ্জি)',
    'Panjabi (পাঞ্জাবি)',
    'Pants / Trousers (প্যান্ট)',
    'Pajama (পায়জামা)',
    'Sari (শাড়ি)',
    'Salwar Kameez (সালোয়ার কামিজ)',
    'Burqa / Hijab (বোরকা / হিজাব)',
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

