const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('../config');

// Clearance tier per role (used by requireAuth([...tiers]) in routes/api.js)
const ROLE_TIERS = {
  external_io: 1,
  forensic_expert: 2,
  cid_officer: 3,
  cib_admin: 5,
};

function requireAuth(allowedTiers = []) {
  return (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'Missing or malformed Authorization header. Bearer token required.',
      });
    }

    const token = authHeader.split(' ')[1];
    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      req.user = decoded;
    } catch (err) {
      return res.status(401).json({
        success: false,
        error: 'Invalid or expired session token. Please re-authenticate.',
      });
    }

    if (allowedTiers.length > 0 && !allowedTiers.includes(req.user.tier)) {
      return res.status(403).json({ success: false, error: 'Access denied for your clearance level.' });
    }
    return next();
  };
}

module.exports = { requireAuth, ROLE_TIERS };
