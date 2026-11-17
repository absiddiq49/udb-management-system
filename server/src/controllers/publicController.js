const store = require('../db/store');

exports.getCases = (req, res) => {
  try {
    const { keywords, gender, ageGroup, division, district, thana, status, hasDna, hasFingerprint } = req.query;

    let filtered = [...store.cases];

    if (gender) {
      filtered = filtered.filter((c) => c.gender.toLowerCase() === gender.toLowerCase());
    }

    if (ageGroup) {
      filtered = filtered.filter((c) => c.ageGroup === ageGroup);
    }

    if (division) {
      filtered = filtered.filter((c) => c.division.toLowerCase() === division.toLowerCase());
    }

    if (district) {
      filtered = filtered.filter((c) => c.district.toLowerCase().includes(district.toLowerCase()));
    }

    if (thana) {
      filtered = filtered.filter((c) => c.thana.toLowerCase().includes(thana.toLowerCase()));
    }

    if (status) {
      filtered = filtered.filter((c) => c.status === status);
    }

    if (hasDna === 'true') {
      filtered = filtered.filter((c) => c.dnaProfileAvailability.toLowerCase().includes('available'));
    }

    if (hasFingerprint === 'true') {
      filtered = filtered.filter((c) => !c.fingerprintAvailability.toLowerCase().includes('unavailable'));
    }

    if (keywords && keywords.trim()) {
      const q = keywords.trim().toLowerCase();
      filtered = filtered.filter((c) => {
        const text = `${c.referenceNo} ${c.gdCaseReference} ${c.placeFound} ${c.identificationMarks} ${c.clothing}`.toLowerCase();
        return text.includes(q);
      });
    }

    // Redact internal notes and autopsy details for public view
    const publicCases = filtered.map((c) => ({
      id: c.id,
      referenceNo: c.referenceNo,
      source: c.source,
      dateFound: c.dateFound,
      timeFound: c.timeFound,
      division: c.division,
      district: c.district,
      thana: c.thana,
      placeFound: c.placeFound,
      locationFound: c.locationFound,
      gender: c.gender,
      estimatedAge: c.estimatedAge,
      ageGroup: c.ageGroup,
      heightCm: c.heightCm,
      weightKg: c.weightKg,
      bodyCondition: c.bodyCondition,
      complexion: c.complexion,
      hair: c.hair,
      facialHair: c.facialHair,
      identificationMarks: c.identificationMarks,
      scars: c.scars,
      tattoos: c.tattoos,
      clothing: c.clothing,
      personalBelongings: c.personalBelongings,
      status: c.status,
      photos: (c.photos || []).map((p) => ({
        id: p.id,
        category: p.category,
        caption: p.caption,
        previewUrl: p.previewUrl,
        isSensitive: p.isSensitive !== false,
      })),
    }));

    return res.json({
      success: true,
      total: publicCases.length,
      records: publicCases,
    });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

exports.getCaseByRef = (req, res) => {
  const { reference } = req.params;
  const match = store.cases.find(
    (c) => c.referenceNo.toLowerCase() === reference.trim().toLowerCase()
  );

  if (!match) {
    return res.status(404).json({ error: 'Deceased record not found' });
  }

  // Redacted public view
  const publicRecord = { ...match };
  delete publicRecord.remarks; // internal confidential notes redacted
  return res.json({ success: true, record: publicRecord });
};

exports.getStatistics = (req, res) => {
  const total = store.cases.length;
  const dnaAvailable = store.cases.filter((c) =>
    c.dnaProfileAvailability.toLowerCase().includes('available')
  ).length;
  const afisAvailable = store.cases.filter(
    (c) => !c.fingerprintAvailability.toLowerCase().includes('unavailable')
  ).length;
  const activeVerification = store.cases.filter((c) =>
    c.status.toLowerCase().includes('verification') || c.status.toLowerCase().includes('active')
  ).length;

  return res.json({
    success: true,
    statistics: {
      totalRecords: total,
      recentRecoveries: total,
      dnaAvailable,
      afisAvailable,
      activeVerification,
    },
  });
};

exports.submitCitizenReport = (req, res) => {
  const {
    reporterName,
    reporterPhone,
    reporterNid,
    division,
    district,
    thana,
    spotLocation,
    description,
    conditionDescription,
  } = req.body;

  if (!reporterName || !reporterPhone || !spotLocation || !description) {
    return res.status(400).json({ error: 'Missing required report fields' });
  }

  const code = `CIT-REP-2026-${(1000 + store.citizenReports.length + 1).toString()}`;
  const report = {
    id: `cit_${Date.now()}`,
    reportReference: code,
    reporterName,
    reporterPhone,
    reporterNid: reporterNid || null,
    division: division || 'Dhaka',
    district: district || 'Dhaka',
    thana: thana || 'General',
    spotLocation,
    dateSpotted: new Date().toISOString().split('T')[0],
    timeSpotted: 'Current',
    description,
    conditionDescription: conditionDescription || 'Not specified',
    status: 'PENDING_POLICE_DISPATCH',
    submittedAt: 'Just now',
  };

  store.citizenReports.unshift(report);
  return res.status(201).json({
    success: true,
    message: 'Emergency report dispatched to CID CIB desk and local police station',
    trackingCode: code,
    report,
  });
};

exports.submitCitizenTip = (req, res) => {
  const {
    bodyReference,
    claimantName,
    claimantPhone,
    claimantEmail,
    relationshipToMissing,
    missingPersonName,
    missingPersonGd,
    thanaFiled,
    similarityReasons,
  } = req.body;

  if (!bodyReference || !claimantName || !claimantPhone || !similarityReasons) {
    return res.status(400).json({ error: 'Missing required tip fields' });
  }

  const tip = {
    id: `tip_${Date.now()}`,
    bodyReference,
    claimantName,
    claimantPhone,
    claimantEmail: claimantEmail || null,
    relationshipToMissing,
    missingPersonName,
    missingPersonGd,
    thanaFiled,
    similarityReasons,
    status: 'NEW_LEAD',
    submittedAt: 'Just now',
  };

  store.tips.unshift(tip);
  return res.status(201).json({
    success: true,
    message: 'Lead submitted. Assigned case officer will review details.',
    tip,
  });
};

