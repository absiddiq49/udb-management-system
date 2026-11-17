const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const store = require('../db/store');
const { JWT_SECRET } = require('../config');
const { ROLE_TIERS } = require('../middleware/auth');
const audit = require('../utils/audit');

// Compared against when the username does not exist, so response time does not reveal valid usernames.
const DUMMY_HASH = bcrypt.hashSync('not-a-real-password', 8);

exports.login = async (req, res) => {
  try {
    const { username, password } = req.body || {};
    if (typeof username !== 'string' || typeof password !== 'string' || !username || !password) {
      return res.status(400).json({ success: false, error: 'Username and password required' });
    }

    const user = store.users.find((u) => u.username.toLowerCase() === username.trim().toLowerCase());
    const passwordOk = bcrypt.compareSync(password, user ? user.password_hash : DUMMY_HASH);

    if (!user || !user.is_active || !passwordOk) {
      audit.log(req, 'LOGIN_FAILED', null, { userId: username.slice(0, 40) });
      return res.status(401).json({ success: false, error: 'Invalid credentials or unauthorized police ID' });
    }

    const tier = ROLE_TIERS[user.role];
    const payload = {
      userId: user.id,
      username: user.username,
      fullName: user.full_name,
      role: user.role,
      tier,
      bpNumber: user.bp_number,
    };
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '8h' });
    audit.log(req, 'LOGIN', null, payload);

    return res.json({
      success: true,
      token,
      user: {
        userId: user.id,
        username: user.username,
        fullName: user.full_name,
        rank: user.rank,
        bpNumber: user.bp_number,
        unitThana: user.unit_thana,
        role: user.role,
        tier,
      },
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: 'Login failed' });
  }
};

exports.tokenLogin = async (req, res) => {
  try {
    const { token } = req.body || {};
    if (typeof token !== 'string' || !token.trim()) {
      return res.status(400).json({ success: false, error: 'Token is required' });
    }

    const clean = token.trim().toUpperCase();
    const match = store.requests.find(
      (r) => r.status === 'approved' && r.accessToken && r.accessToken.toUpperCase() === clean
    );

    const expiresAtMs = match && match.expiresAt ? Date.parse(match.expiresAt) : NaN;
    if (!match || !(expiresAtMs > Date.now())) {
      audit.log(req, 'TOKEN_LOGIN_FAILED', null, { userId: 'token' });
      return res.status(403).json({ success: false, error: 'Invalid or expired access token' });
    }

    const payload = {
      userId: match.id,
      username: match.bpNumber,
      fullName: match.officerName,
      role: 'external_io',
      tier: ROLE_TIERS.external_io,
      bpNumber: match.bpNumber,
      targetCaseReference: match.targetCaseReference,
    };
    // The session can never outlive the pass itself (max 7 days).
    const ttlSeconds = Math.max(60, Math.min(7 * 24 * 3600, Math.floor((expiresAtMs - Date.now()) / 1000)));
    const jwtToken = jwt.sign(payload, JWT_SECRET, { expiresIn: ttlSeconds });
    audit.log(req, 'TOKEN_LOGIN', match.targetCaseReference, payload);

    return res.json({
      success: true,
      token: jwtToken,
      user: {
        userId: match.id,
        username: match.bpNumber,
        fullName: match.officerName,
        rank: match.officerRank,
        bpNumber: match.bpNumber,
        unitThana: match.postingUnit,
        role: 'external_io',
        tier: ROLE_TIERS.external_io,
        authorizedCases: [match.targetCaseReference],
      },
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: 'Token login failed' });
  }
};

// requireAuth() has already verified the token and set req.user
exports.getMe = (req, res) => res.json({ success: true, user: req.user });
