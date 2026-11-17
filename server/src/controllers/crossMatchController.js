const store = require('../db/store');
const { toPublicRecord } = require('../utils/redact');

const toInt = (v) => {
  const n = parseInt(v, 10);
  return Number.isFinite(n) ? n : null;
};

// Algorithmic 5-vector similarity engine modeled on Interpol DVI & US NamUs
exports.executeCrossMatch = (req, res) => {
  const { gender, age, heightCm, district, keywords, clothesKeywords } = req.body;

  const targetGender = (gender || '').toLowerCase().trim();
  const targetAge = toInt(age);
  const targetHeight = toInt(heightCm);
  const targetDistrict = (district || '').toLowerCase().trim();
  const kwList = (keywords || '')
    .toLowerCase()
    .split(/[\s,]+/)
    .filter((k) => k.length > 2);
  const clothesList = (clothesKeywords || '')
    .toLowerCase()
    .split(/[\s,]+/)
    .filter((k) => k.length > 2);

  const scoredResults = store.cases.map((record) => {
    let score = 0;
    const breakdown = {};

    // 1. Biological Sex Vector (30%)
    if (targetGender.length > 0) {
      if (record.gender.toLowerCase() === targetGender) {
        score += 30;
        breakdown.sex = 30;
      } else {
        breakdown.sex = 0;
      }
    } else {
      score += 15;
      breakdown.sex = 15;
    }

    // 2. Age Range Vector (25%)
    if (targetAge !== null) {
      const diff = Math.abs(record.estimatedAge - targetAge);
      if (diff <= 3) {
        score += 25;
        breakdown.age = 25;
      } else if (diff <= 8) {
        score += 18;
        breakdown.age = 18;
      } else if (diff <= 15) {
        score += 10;
        breakdown.age = 10;
      } else {
        breakdown.age = 0;
      }
    } else {
      score += 12;
      breakdown.age = 12;
    }

    // 3. Stature / Height Vector (20%)
    if (targetHeight !== null) {
      const diff = Math.abs(record.heightCm - targetHeight);
      if (diff <= 4) {
        score += 20;
        breakdown.height = 20;
      } else if (diff <= 8) {
        score += 14;
        breakdown.height = 14;
      } else if (diff <= 15) {
        score += 7;
        breakdown.height = 7;
      } else {
        breakdown.height = 0;
      }
    } else {
      score += 10;
      breakdown.height = 10;
    }

    // 4. Geographic Vector (10%)
    if (targetDistrict.length > 0) {
      if (record.district.toLowerCase() === targetDistrict) {
        score += 10;
        breakdown.district = 10;
      } else {
        breakdown.district = 0;
      }
    } else {
      score += 5;
      breakdown.district = 5;
    }

    // 5. Identifying Marks, Tattoos & Clothing Descriptor Vector (15%)
    let markHits = 0;
    const bodyCorpus = `${record.identificationMarks} ${record.scars} ${record.tattoos} ${record.clothing}`.toLowerCase();
    for (const kw of [...kwList, ...clothesList]) {
      if (bodyCorpus.includes(kw)) {
        markHits++;
      }
    }
    const marksScore = Math.min(15, markHits * 6);
    score += marksScore;
    breakdown.marks = marksScore;

    return {
      record: toPublicRecord(record), // public endpoint: never return unredacted data
      score: Math.min(100, Math.round(score)),
      breakdown,
    };
  });

  // Sort descending by score
  scoredResults.sort((a, b) => b.score - a.score);

  // Return top 15 matches
  const topMatches = scoredResults.slice(0, 15);

  res.json({
    success: true,
    totalEvaluated: store.cases.length,
    matches: topMatches,
  });
};

