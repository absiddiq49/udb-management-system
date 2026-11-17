const { store } = require('../db/store');

// External IO Access Request Submission (Public endpoint)
exports.submitIoRequest = (req, res) => {
  const {
    officerName,
    bpNumber,
    designation,
    policeUnit,
    district,
    phone,
    email,
    caseGrounds,
    requestedCaseReference,
  } = req.body;

  if (!officerName || !bpNumber || !requestedCaseReference || !phone) {
    return res.status(400).json({
      success: false,
      error: 'officerName, bpNumber, requestedCaseReference, and phone are mandatory fields.',
    });
  }

  const reqId = `req_${Date.now()}`;
  const trackingCode = `REQ-2026-${Math.floor(1000 + Math.random() * 9000)}`;

  const newRequest = {
    id: reqId,
    trackingCode,
    officerName,
    bpNumber,
    designation: designation || 'Sub-Inspector',
    policeUnit: policeUnit || 'Thana Investigation',
    district: district || 'Dhaka',
    phone,
    email: email || '',
    caseGrounds: caseGrounds || '',
    requestedCaseReference,
    status: 'PENDING_VERIFICATION',
    assignedToken: null,
    submittedAt: new Date().toISOString(),
    reviewedAt: null,
    reviewedBy: null,
  };

  store.ioRequests.unshift(newRequest);

  res.status(201).json({
    success: true,
    data: newRequest,
    message: 'IO access request submitted. Awaiting Central Intelligence Bureau verification.',
  });
};

// List all IO requests (Official Tier 1-5)
exports.listIoRequests = (req, res) => {
  res.json({
    success: true,
    data: store.ioRequests,
    total: store.ioRequests.length,
  });
};

// Approve an IO access request and issue a 72-hour pass token (Tier 3-5 only)
exports.approveIoRequest = (req, res) => {
  const { id } = req.params;
  const request = store.ioRequests.find((r) => r.id === id || r.trackingCode === id);

  if (!request) {
    return res.status(404).json({ success: false, error: 'IO Request not found.' });
  }

  const tokenSuffix = Math.random().toString(36).substring(2, 6).toUpperCase();
  const token = `CID-PASS-${Math.floor(1000 + Math.random() * 9000)}-${tokenSuffix}`;

  request.status = 'APPROVED';
  request.assignedToken = token;
  request.reviewedAt = new Date().toISOString();
  request.reviewedBy = req.user ? `${req.user.fullName} (${req.user.bpNumber})` : 'SP CIB HQ';

  // Register the token in the store so the IO can log in with it
  store.validIoTokens[token] = {
    targetCaseReference: request.requestedCaseReference,
    officerName: request.officerName,
    bpNumber: request.bpNumber,
    unit: request.policeUnit,
    expiresAt: new Date(Date.now() + 72 * 3600 * 1000).toISOString(),
  };

  res.json({
    success: true,
    data: request,
    message: `Access approved. Token ${token} generated and dispatched via police SMS gateway.`,
  });
};

// Reject an IO access request
exports.rejectIoRequest = (req, res) => {
  const { id } = req.params;
  const { reason } = req.body;
  const request = store.ioRequests.find((r) => r.id === id || r.trackingCode === id);

  if (!request) {
    return res.status(404).json({ success: false, error: 'IO Request not found.' });
  }

  request.status = 'REJECTED';
  request.reviewedAt = new Date().toISOString();
  request.reviewedBy = req.user ? `${req.user.fullName} (${req.user.bpNumber})` : 'SP CIB HQ';
  request.rejectionReason = reason || 'Insufficient jurisdictional grounds provided.';

  res.json({
    success: true,
    data: request,
    message: 'IO Request rejected.',
  });
};

// List Citizen Reports (Official)
exports.listCitizenReports = (req, res) => {
  res.json({
    success: true,
    data: store.citizenReports,
    total: store.citizenReports.length,
  });
};

// List Citizen Relative Match Tips (Official)
exports.listCitizenTips = (req, res) => {
  res.json({
    success: true,
    data: store.citizenTips,
    total: store.citizenTips.length,
  });
};

