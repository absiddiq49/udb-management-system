const crypto = require('crypto');
const store = require('../db/store');
const { toPublicRecord } = require('../utils/redact');

const clean = (v, max = 300) => (typeof v === 'string' ? v.trim().slice(0, max) : '');
const has = (v, needle) => String(v || '').toLowerCase().includes(String(needle).toLowerCase());

exports.getCases = (req, res) => {
  const q = req.query;
  const eq = (a, b) => String(a || '').toLowerCase() === String(b).toLowerCase();

  let list = store.cases;
  if (q.gender) list = list.filter((c) => eq(c.gender, q.gender));
  if (q.ageGroup) list = list.filter((c) => c.ageGroup === q.ageGroup);
  if (q.division) list = list.filter((c) => eq(c.division, q.division));
  if (q.district) list = list.filter((c) => has(c.district, q.district));
  if (q.thana) list = list.filter((c) => has(c.thana, q.thana));
  if (q.status) list = list.filter((c) => c.status === q.status);
  if (q.hasDna === 'true') list = list.filter((c) => has(c.dnaProfileAvailability, 'available'));
  if (q.hasFingerprint === 'true') list = list.filter((c) => !has(c.fingerprintAvailability, 'unavailable'));
  if (typeof q.keywords === 'string' && q.keywords.trim()) {
    const kw = q.keywords.trim();
    list = list.filter((c) =>
      has(`${c.referenceNo} ${c.gdCaseReference} ${c.placeFound} ${c.identificationMarks} ${c.clothing}`, kw)
    );
  }

  // Pagination (defaults keep the old behaviour for small data sets)
  const limit = Math.min(Math.max(parseInt(q.limit, 10) || 50, 1), 100);
  const page = Math.max(parseInt(q.page, 10) || 1, 1);
  const slice = list.slice((page - 1) * limit, page * limit);

  return res.json({
    success: true,
    total: list.length,
    page,
    limit,
    records: slice.map(toPublicRecord),
  });
};

exports.getCaseByRef = (req, res) => {
  const ref = String(req.params.ref || '').trim().toLowerCase();
  const match = store.cases.find((c) => c.referenceNo.toLowerCase() === ref);
  if (!match) return res.status(404).json({ success: false, error: 'Deceased record not found' });
  return res.json({ success: true, record: toPublicRecord(match) });
};

exports.getStatistics = (req, res) => {
  const total = store.cases.length;
  return res.json({
    success: true,
    statistics: {
      totalRecords: total,
      recentRecoveries: total,
      dnaAvailable: store.cases.filter((c) => has(c.dnaProfileAvailability, 'available')).length,
      afisAvailable: store.cases.filter((c) => !has(c.fingerprintAvailability, 'unavailable')).length,
      activeVerification: store.cases.filter((c) => has(c.status, 'verification') || has(c.status, 'active')).length,
    },
  });
};

exports.submitCitizenReport = (req, res) => {
  const b = req.body || {};
  const reporterName = clean(b.reporterName, 120);
  const reporterPhone = clean(b.reporterPhone, 30);
  const spotLocation = clean(b.spotLocation, 300);
  const description = clean(b.description, 2000);

  if (!reporterName || !reporterPhone || !spotLocation || !description) {
    return res.status(400).json({ success: false, error: 'Missing required report fields' });
  }

  const code = `CIT-REP-2026-${(1000 + store.citizenReports.length + 1).toString()}`;
  const report = {
    id: `cit_${crypto.randomUUID()}`,
    reportReference: code,
    reporterName,
    reporterPhone,
    reporterNid: clean(b.reporterNid, 30) || null,
    division: clean(b.division, 60) || 'Dhaka',
    district: clean(b.district, 60) || 'Dhaka',
    thana: clean(b.thana, 80) || 'General',
    spotLocation,
    dateSpotted: new Date().toISOString().split('T')[0],
    timeSpotted: 'Current',
    description,
    conditionDescription: clean(b.conditionDescription, 1000) || 'Not specified',
    status: 'PENDING_POLICE_DISPATCH',
    submittedAt: new Date().toISOString(),
  };

  store.citizenReports.unshift(report);
  // The tracking code is enough for the citizen; personal data is not echoed back.
  return res.status(201).json({
    success: true,
    message: 'Emergency report dispatched to CID CIB desk and local police station',
    trackingCode: code,
  });
};

exports.submitCitizenTip = (req, res) => {
  const b = req.body || {};
  const bodyReference = clean(b.bodyReference, 60);
  const claimantName = clean(b.claimantName, 120);
  const claimantPhone = clean(b.claimantPhone, 30);
  const similarityReasons = clean(b.similarityReasons, 2000);

  if (!bodyReference || !claimantName || !claimantPhone || !similarityReasons) {
    return res.status(400).json({ success: false, error: 'Missing required tip fields' });
  }
  if (!store.cases.some((c) => c.referenceNo.toLowerCase() === bodyReference.toLowerCase())) {
    return res.status(404).json({ success: false, error: 'Unknown deceased record reference' });
  }

  const tip = {
    id: `tip_${crypto.randomUUID()}`,
    bodyReference,
    claimantName,
    claimantPhone,
    claimantEmail: clean(b.claimantEmail, 160) || null,
    relationshipToMissing: clean(b.relationshipToMissing, 80),
    missingPersonName: clean(b.missingPersonName, 120),
    missingPersonGd: clean(b.missingPersonGd, 80),
    thanaFiled: clean(b.thanaFiled, 80),
    similarityReasons,
    status: 'NEW_LEAD',
    submittedAt: new Date().toISOString(),
  };

  store.tips.unshift(tip);
  return res.status(201).json({
    success: true,
    message: 'Lead submitted. Assigned case officer will review details.',
    tipId: tip.id,
  });
};
