import '../models/udb_record.dart';

class MissingPersonProfile {
  final String fullName;
  final String gdNumber;
  final String thana;
  final String district;
  final String gender;
  final int age;
  final int heightCm;
  final String distinguishingMarks;
  final String lastSeenClothing;
  final String dateMissing;

  const MissingPersonProfile({
    required this.fullName,
    required this.gdNumber,
    required this.thana,
    required this.district,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.distinguishingMarks,
    required this.lastSeenClothing,
    required this.dateMissing,
  });
}

class MatchScoreResult {
  final UdbRecord record;
  final double score; // 0 to 100
  final List<String> matchReasons;
  final double sexScore; // 0 to 30
  final double ageScore; // 0 to 25
  final double heightScore; // 0 to 20
  final double districtScore; // 0 to 10
  final double keywordScore; // 0 to 15

  const MatchScoreResult({
    required this.record,
    required this.score,
    required this.matchReasons,
    this.sexScore = 0,
    this.ageScore = 0,
    this.heightScore = 0,
    this.districtScore = 0,
    this.keywordScore = 0,
  });

  String get confidenceLevel {
    if (score >= 85) return 'High Probable Match';
    if (score >= 65) return 'Moderate Similarity';
    return 'Potential Lead';
  }
}

class CrossMatchingService {
  static List<MissingPersonProfile> get sampleProfiles => [
    const MissingPersonProfile(
      fullName: 'Md. Rafiqul Islam',
      gdNumber: 'Ramna PS Missing GD No. 442/2026',
      thana: 'Ramna',
      district: 'Dhaka',
      gender: 'Male',
      age: 28,
      heightCm: 170,
      distinguishingMarks: 'Cut mark above left eyebrow, mole on right cheek, steel ring',
      lastSeenClothing: 'Blue check shirt, dark trousers, sandals',
      dateMissing: '2026-07-27',
    ),
    const MissingPersonProfile(
      fullName: 'Nasreen Begum',
      gdNumber: 'Kotwali PS Missing GD No. 109/2026',
      thana: 'Kotwali',
      district: 'Chattogram',
      gender: 'Female',
      age: 42,
      heightCm: 158,
      distinguishingMarks: 'Burn scar on forearm, red bangles, pierced ears',
      lastSeenClothing: 'Maroon salwar kameez, black shawl',
      dateMissing: '2026-07-20',
    ),
    const MissingPersonProfile(
      fullName: 'Sumon Kanti Das',
      gdNumber: 'Jalalabad PS GD No. 63/2026',
      thana: 'Jalalabad',
      district: 'Sylhet',
      gender: 'Unknown',
      age: 18,
      heightCm: 155,
      distinguishingMarks: 'Faded cursive tattoo initials S K on left inner wrist',
      lastSeenClothing: 'Dark grey hoodie with fleece lining, black track pants with stripes',
      dateMissing: '2026-05-24',
    ),
  ];

  static List<MatchScoreResult> calculateMatches({
    required MissingPersonProfile missing,
    required List<UdbRecord> records,
  }) {
    final List<MatchScoreResult> results = [];

    for (final record in records) {
      double score = 0;
      final reasons = <String>[];
      double sexScore = 0;
      double ageScore = 0;
      double heightScore = 0;
      double districtScore = 0;
      double keywordScore = 0;

      // 1. Biological Sex (30 points)
      if (record.gender.toLowerCase() == missing.gender.toLowerCase()) {
        sexScore = 30;
        reasons.add('Biological sex aligns (${record.gender})');
      } else if (record.gender.toLowerCase() == 'unknown') {
        sexScore = 15;
        reasons.add('Dead body gender is pending confirmation');
      }
      score += sexScore;

      // 2. Age proximity (25 points)
      final ageDiff = (record.estimatedAge - missing.age).abs();
      if (ageDiff <= 3) {
        ageScore = 25;
        reasons.add('Estimated age matches closely (within ±$ageDiff years)');
      } else if (ageDiff <= 8) {
        ageScore = 15;
        reasons.add('Estimated age within probable range (±$ageDiff years)');
      } else if (ageDiff <= 15) {
        ageScore = 5;
      }
      score += ageScore;

      // 3. Stature / Height proximity (20 points)
      final heightDiff = (record.heightCm - missing.heightCm).abs();
      if (heightDiff <= 4) {
        heightScore = 20;
        reasons.add('Height matches within ±$heightDiff cm');
      } else if (heightDiff <= 10) {
        heightScore = 10;
        reasons.add('Height within acceptable margin (±$heightDiff cm)');
      }
      score += heightScore;

      // 4. District / Regional Proximity (10 points)
      if (record.district.toLowerCase() == missing.district.toLowerCase()) {
        districtScore = 10;
        reasons.add('Recovered in the same district (${record.district})');
      }
      score += districtScore;

      // 5. Keyword search in marks & clothing (15 points)
      final textBlob = '${record.identificationMarks} ${record.scars} ${record.tattoos} ${record.clothing} ${record.personalBelongings}'.toLowerCase();
      final queryKeywords = '${missing.distinguishingMarks} ${missing.lastSeenClothing}'
          .toLowerCase()
          .split(RegExp(r'[\s,;]+'))
          .where((k) => k.length > 3)
          .toList();

      int keywordHits = 0;
      for (final kw in queryKeywords) {
        if (textBlob.contains(kw)) {
          keywordHits++;
        }
      }

      if (keywordHits > 0) {
        keywordScore = (keywordHits * 5).clamp(0, 15).toDouble();
        score += keywordScore;
        reasons.add('$keywordHits distinctive physical/clothing marker keyword(s) matched');
      }

      if (score >= 30) {
        results.add(MatchScoreResult(
          record: record,
          score: score.clamp(0, 100),
          matchReasons: reasons,
          sexScore: sexScore,
          ageScore: ageScore,
          heightScore: heightScore,
          districtScore: districtScore,
          keywordScore: keywordScore,
        ));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}

