const { store } = require('../db/store');

// Get unredacted official dossier (Requires Tier 1-5)
exports.getOfficialDossier = (req, res) => {
  const { ref } = req.params;
  const record = store.records.find((r) => r.referenceNo === ref || r.id === ref);

  if (!record) {
    return res.status(404).json({ success: false, error: 'Deceased record not found.' });
  }

  // If officer is an external IO (Tier 1), ensure they only access their approved case
  if (req.user && req.user.tier === 1 && req.user.targetCaseReference) {
    if (req.user.targetCaseReference !== record.referenceNo) {
      return res.status(403).json({
        success: false,
        error: `Access restricted. Your IO token is restricted to case ${req.user.targetCaseReference}`,
      });
    }
  }

  // Add watermarking header information
  const auditStamp = {
    viewedBy: req.user ? `${req.user.fullName} (${req.user.bpNumber})` : 'Official',
    timestamp: new Date().toISOString(),
    watermarkNotice: `CONFIDENTIAL POLICE DOSSIER - AUDITED BY CID CIB FOR BP #${req.user?.bpNumber || 'OFFICIAL'}`,
  };

  res.json({
    success: true,
    data: record,
    audit: auditStamp,
  });
};

// Create new Unidentified Dead Body Record (Requires Tier 3-5)
exports.createRecord = (req, res) => {
  const data = req.body;

  if (!data.gender || !data.district || !data.thana || !data.dateFound) {
    return res.status(400).json({
      success: false,
      error: 'gender, district, thana, and dateFound are required parameters.',
    });
  }

  const newId = `udb_${Date.now()}`;
  const seq = 100 + store.records.length + 1;
  const refNo = `CID-UDB-2026-${seq}`;

  const newRecord = {
    id: newId,
    referenceNo: refNo,
    gender: data.gender,
    estimatedAge: parseInt(data.estimatedAge, 10) || 30,
    ageGroup: data.ageGroup || 'Adult (25-45)',
    heightCm: parseInt(data.heightCm, 10) || 165,
    weightKg: parseInt(data.weightKg, 10) || 60,
    bodyCondition: data.bodyCondition || 'Fresh / Intact',
    dateFound: data.dateFound,
    timeFound: data.timeFound || 'Morning',
    district: data.district,
    division: data.division || 'Dhaka',
    thana: data.thana,
    placeFound: data.placeFound || 'Roadside / Open ground',
    locationFound: data.locationFound || `${data.thana}, ${data.district}`,
    gdCaseReference: data.gdCaseReference || `${data.thana} PS GD 01/2026`,
    recoveryOfficerUnit: data.recoveryOfficerUnit || 'Thana Patrol Unit',
    complexion: data.complexion || 'Medium / Wheatish',
    hair: data.hair || 'Black',
    facialHair: data.facialHair || 'Clean Shaven',
    clothing: data.clothing || 'Standard apparel',
    personalBelongings: data.personalBelongings || 'None found',
    identificationMarks: data.identificationMarks || 'None visible',
    scars: data.scars || 'None',
    tattoos: data.tattoos || 'None',
    birthmarks: data.birthmarks || 'None',
    dentalCharacteristics: data.dentalCharacteristics || 'Natural dentition',
    status: 'ACTIVE - UNDER INVESTIGATION',
    primaryPhoto: null,
    photos: [],
    documents: [
      {
        id: `doc_${Date.now()}_1`,
        title: 'Inquest Report (CrPC Section 174)',
        type: 'inquest_report',
        fileFormat: 'pdf',
        fileSizeBytes: 2450000,
        sha256Hash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        classification: 'RESTRICTED_OFFICIAL',
        uploadedAt: new Date().toISOString(),
        downloadUrl: '/api/v1/documents/inquest-sample.pdf',
      },
    ],
    fingerprintAvailability: data.hasFingerprint ? 'Full 10-Print Taken (AFIS Search Ready)' : 'None',
    dnaProfileAvailability: data.hasDna ? 'Bone Marrow Archived (CID Forensic DNA Lab)' : 'None',
    postmortemReference: data.postmortemReference || 'DMC-PM-2026-PENDING',
    createdDate: new Date().toISOString().split('T')[0],
  };

  store.records.unshift(newRecord);

  res.status(201).json({
    success: true,
    data: newRecord,
    message: `Record ${refNo} officially registered in CID Central Deceased Registry.`,
  });
};

// Update Case Status (Requires Tier 3-5)
exports.updateCaseStatus = (req, res) => {
  const { ref } = req.params;
  const { status, statusNotes } = req.body;

  const record = store.records.find((r) => r.referenceNo === ref || r.id === ref);
  if (!record) {
    return res.status(404).json({ success: false, error: 'Deceased record not found.' });
  }

  record.status = status || record.status;
  if (statusNotes) {
    record.statusNotes = statusNotes;
  }

  res.json({
    success: true,
    data: record,
    message: `Case status for ${record.referenceNo} updated to ${record.status}.`,
  });
};

// Add Forensic Document or Evidence Note
exports.addDocument = (req, res) => {
  const { ref } = req.params;
  const { title, type, fileFormat, classification } = req.body;

  const record = store.records.find((r) => r.referenceNo === ref || r.id === ref);
  if (!record) {
    return res.status(404).json({ success: false, error: 'Deceased record not found.' });
  }

  const newDoc = {
    id: `doc_${Date.now()}`,
    title: title || 'Forensic Case Attachment',
    type: type || 'evidence_memo',
    fileFormat: fileFormat || 'pdf',
    fileSizeBytes: 1850000,
    sha256Hash: 'a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e',
    classification: classification || 'RESTRICTED_OFFICIAL',
    uploadedAt: new Date().toISOString(),
    downloadUrl: '/api/v1/documents/sample.pdf',
  };

  record.documents.push(newDoc);

  res.status(201).json({
    success: true,
    data: newDoc,
    message: 'Forensic document linked to case registry.',
  });
};

