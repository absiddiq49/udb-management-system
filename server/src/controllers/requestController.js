const crypto = require('crypto');
const store = require('../db/store');
const audit = require('../utils/audit');

const clean = (v, max = 300) => (typeof v === 'string' ? v.trim().slice(0, max) : '');

// External IO Access Request Submission (public endpoint)
exports.submitIoRequest = (req, res) => {
  const b = req.body || {};
  const officerName = clean(b.officerName, 120);
  const bpNumber = clean(b.bpNumber, 40);
  const contactPhone = clean(b.phone || b.contactPhone, 30);
  const targetCaseReference = clean(b.requestedCaseReference || b.targetCaseReference, 60);

  if (!officerName || !bpNumber || !contactPhone || !targetCaseReference) {
    return res.status(400).json({
      success: false,
      error: 'officerName, bpNumber, phone and requestedCaseReference are mandatory fields.',
    });
  }

  const requestCode = `REQ-2026-${(1000 + store.requests.length + 1).toString()}`;
  const request = {
    id: `req_${crypto.randomUUID()}`,
    requestCode,
    officerName,
    officerRank: clean(b.designation || b.officerRank, 80) || 'Sub-Inspector',
    bpNumber,
    postingUnit: clean(b.policeUnit || b.postingUnit, 160) || 'Thana Investigation',
    contactPhone,
    officialEmail: clean(b.email || b.officialEmail, 160),
    targetCaseReference,
    investigationGdFir: clean(b.investigationGdFir, 160),
    reasonForAccess: clean(b.caseGrounds || b.reasonForAccess, 1500),
    status: 'pending',
    requestedAt: new Date().toISOString(),
  };

  store.requests.unshift(request);
  return res.status(201).json({
    success: true,
    data: { requestCode, status: request.status },
    message: 'IO access request submitted. Awaiting Central Intelligence Bureau verification.',
  });
};

exports.listIoRequests = (req, res) => {
  res.json({ success: true, data: store.requests, total: store.requests.length });
};

function findRequest(id) {
  return store.requests.find((r) => r.id === id || r.requestCode === id);
}

// Approve a pending request and issue a 72-hour pass (Tier 3-5 only)
exports.approveIoRequest = (req, res) => {
  const request = findRequest(req.params.id);
  if (!request) return res.status(404).json({ success: false, error: 'IO Request not found.' });
  if (request.status !== 'pending') {
    return res.status(409).json({ success: false, error: `Request is already ${request.status}.` });
  }

  const hex = crypto.randomBytes(8).toString('hex').toUpperCase(); // 64 bits of randomness
  const token = `CID-PASS-${hex.match(/.{4}/g).join('-')}`;

  request.status = 'approved';
  request.accessToken = token;
  request.expiresAt = new Date(Date.now() + 72 * 3600 * 1000).toISOString();
  request.tokenExpiresAt = request.expiresAt;
  request.reviewedAt = new Date().toISOString();
  request.reviewedBy = `${req.user.fullName} (${req.user.bpNumber})`;

  audit.log(req, 'IO_REQUEST_APPROVED', request.requestCode);
  res.json({
    success: true,
    data: request,
    message: 'Access approved. Send the pass to the officer through an official channel.',
  });
};

exports.rejectIoRequest = (req, res) => {
  const request = findRequest(req.params.id);
  if (!request) return res.status(404).json({ success: false, error: 'IO Request not found.' });
  if (request.status !== 'pending') {
    return res.status(409).json({ success: false, error: `Request is already ${request.status}.` });
  }

  request.status = 'rejected';
  request.reviewedAt = new Date().toISOString();
  request.reviewedBy = `${req.user.fullName} (${req.user.bpNumber})`;
  request.reviewNotes = clean((req.body || {}).reason, 500) || 'Insufficient jurisdictional grounds provided.';

  audit.log(req, 'IO_REQUEST_REJECTED', request.requestCode);
  res.json({ success: true, data: request, message: 'IO Request rejected.' });
};

exports.listCitizenReports = (req, res) => {
  res.json({ success: true, data: store.citizenReports, total: store.citizenReports.length });
};

exports.listCitizenTips = (req, res) => {
  res.json({ success: true, data: store.tips, total: store.tips.length });
};
