// Single place that decides what the PUBLIC may see (whitelist, not blacklist).
// Autopsy details, documents/hashes, lab references and officer remarks are never included.
const PUBLIC_FIELDS = [
  'id', 'referenceNo', 'source', 'dateFound', 'timeFound',
  'division', 'district', 'thana', 'placeFound', 'locationFound',
  'gdCaseReference', 'recoveryOfficerUnit',
  'gender', 'estimatedAge', 'ageGroup', 'heightCm', 'weightKg',
  'bodyCondition', 'complexion', 'hair', 'facialHair',
  'identificationMarks', 'scars', 'tattoos', 'clothing', 'personalBelongings',
  'status',
];

function toPublicRecord(record) {
  const out = {};
  for (const key of PUBLIC_FIELDS) out[key] = record[key];
  out.photos = (record.photos || []).map((p) => ({
    id: p.id,
    category: p.category,
    caption: p.caption,
    previewUrl: p.previewUrl,
    isSensitive: p.isSensitive !== false, // sensitive unless explicitly marked safe
  }));
  return out;
}

module.exports = { toPublicRecord, PUBLIC_FIELDS };
