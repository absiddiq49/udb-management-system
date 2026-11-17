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

  const MatchScoreResult({
    required this.record,
    required this.score,
    required this.matchReasons,
  });
}

class CrossMatchingService {
  static List<MatchScoreResult> calculateMatches({
    required MissingPersonProfile missing,
    required List<UdbRecord> records,
  }) {
    final List<MatchScoreResult> results = [];

    for (final record in records) {
      double score = 0;
      final reasons = <String>[];

      // 1. Biological Sex (30 points)
      if (record.gender.toLowerCase() == missing.gender.toLowerCase()) {
        score += 30;
        reasons.add('Biological sex aligns (${record.gender})');
      } else if (record.gender.toLowerCase() == 'unknown') {
        score += 15;
        reasons.add('Deceased gender is pending confirmation');
      }

      // 2. Age proximity (25 points)
      final ageDiff = (record.estimatedAge - missing.age).abs();
      if (ageDiff <= 3) {
        score += 25;
        reasons.add('Estimated age matches closely (within ±$ageDiff years)');
      } else if (ageDiff <= 8) {
        score += 15;
        reasons.add('Estimated age within probable range (±$ageDiff years)');
      } else if (ageDiff <= 15) {
        score += 5;
      }

      // 3. Stature / Height proximity (20 points)
      final heightDiff = (record.heightCm - missing.heightCm).abs();
      if (heightDiff <= 4) {
        score += 20;
        reasons.add('Height matches within ±$heightDiff cm');
      } else if (heightDiff <= 10) {
        score += 10;
        reasons.add('Height within acceptable margin (±$heightDiff cm)');
      }

      // 4. District / Regional Proximity (10 points)
      if (record.district.toLowerCase() == missing.district.toLowerCase()) {
        score += 10;
        reasons.add('Recovered in the same district (${record.district})');
      }

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
        final kwPoints = (keywordHits * 5).clamp(0, 15).toDouble();
        score += kwPoints;
        reasons.add('$keywordHits distinctive physical/clothing marker keyword(s) matched');
      }

      if (score >= 35) {
        results.add(MatchScoreResult(
          record: record,
          score: score.clamp(0, 100),
          matchReasons: reasons,
        ));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}

