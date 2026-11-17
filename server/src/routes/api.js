const express = require('express');
const router = express.Router();

const authController = require('../controllers/authController');
const publicController = require('../controllers/publicController');
const requestController = require('../controllers/requestController');
const officialController = require('../controllers/officialController');
const crossMatchController = require('../controllers/crossMatchController');
const { requireAuth } = require('../middleware/auth');
const { rateLimit } = require('../middleware/security');

const loginLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 10, message: 'Too many login attempts. Try again in 15 minutes.' });
const submitLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 15 });
const searchLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 60 });

// ==========================================
// 1. PUBLIC CITIZEN ENDPOINTS (Tier 0 - No Auth)
// ==========================================

// Search / Filter Deceased Public Gazettes
router.get('/public/records', publicController.getCases);

// Get single Redacted Public Dossier & Gazette Notice
router.get('/public/records/:ref', publicController.getCaseByRef);

// Submit Citizen Tip / Recognition Lead
router.post('/public/tips', submitLimiter, publicController.submitCitizenTip);

// Report Found Body / Human Remains (Emergency Intake)
router.post('/public/reports', submitLimiter, publicController.submitCitizenReport);

// Submit External IO Data Access Request
router.post('/public/io-requests', submitLimiter, requestController.submitIoRequest);

// Cross-Match Engine (Accessible for public relatives searching missing persons)
router.post('/public/cross-match', searchLimiter, crossMatchController.executeCrossMatch);

// System KPI Statistics Strip
router.get('/public/kpis', publicController.getStatistics);


// ==========================================
// 2. AUTHENTICATION & ACCESS PASS ENDPOINTS
// ==========================================

// Police Officer Username/Password Login (CID & Station Officers)
router.post('/auth/login', loginLimiter, authController.login);

// Validate 72h External IO Pass Token
router.post('/auth/validate-token', loginLimiter, authController.tokenLogin);

// Verify active session & role
router.get('/auth/me', requireAuth(), authController.getMe);


// ==========================================
// 3. OFFICIAL DOSSIER & REGISTRY (Tier 1-5 Auth)
// ==========================================

// Get unredacted official dossier (Tier 1-5, with case check for Tier 1 IOs)
router.get('/official/records/:ref', requireAuth([1, 2, 3, 4, 5]), officialController.getOfficialDossier);

// Register New Unidentified Dead Body Case (Tier 3-5: CID Officers & Admins)
router.post('/official/records', requireAuth([3, 4, 5]), officialController.createRecord);

// Update Case Status & Medico-legal Disposition (Tier 3-5)
router.patch('/official/records/:ref/status', requireAuth([3, 4, 5]), officialController.updateCaseStatus);

// Upload / Link Forensic Attachment (Tier 2-5: Medico-legal & CID Officers)
router.post('/official/records/:ref/documents', requireAuth([2, 3, 4, 5]), officialController.addDocument);


// ==========================================
// 4. CIB REQUEST MANAGEMENT QUEUE (Tier 3-5 Auth)
// ==========================================

// List IO Access Requests
router.get('/official/io-requests', requireAuth([3, 4, 5]), requestController.listIoRequests);

// Approve IO Request & Generate Token
router.post('/official/io-requests/:id/approve', requireAuth([3, 4, 5]), requestController.approveIoRequest);

// Reject IO Request
router.post('/official/io-requests/:id/reject', requireAuth([3, 4, 5]), requestController.rejectIoRequest);

// List Citizen Reports (Emergency Influx Queue)
router.get('/official/citizen-reports', requireAuth([3, 4, 5]), requestController.listCitizenReports);

// List Relative Match Tips
router.get('/official/citizen-tips', requireAuth([3, 4, 5]), requestController.listCitizenTips);

// Audit trail (Tier 5: CIB admin only)
router.get('/official/audit-logs', requireAuth([5]), officialController.listAuditLogs);

module.exports = router;
