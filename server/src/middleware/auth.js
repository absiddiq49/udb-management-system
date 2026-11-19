const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('../config');
const { auth, CLEARANCE_TIERS } = require('../auth');

const ROLE_TIERS = {
  citizen: 0,
  external_io: 1,
  forensic_expert: 2,
  cid_officer: 3,
  cib_admin: 5,
  super_admin: 5,
};

function requireAuth(allowedTiers = []) {
  return async (req, res, next) => {
    // 1. Check BetterAuth session via cookie/headers
    try {
      const session = await auth.api.getSession({
        headers: req.headers,
      });
      if (session && session.user) {
        req.user = {
          id: session.user.id,
          username: session.user.email ? session.user.email.split('@')[0] : session.user.name,
          email: session.user.email,
          fullName: session.user.name,
          role: session.user.role || 'citizen',
          tier: session.user.tier !== undefined ? session.user.tier : (ROLE_TIERS[session.user.role] || 0),
          bpNumber: session.user.bpNumber,
          rank: session.user.rank,
          designation: session.user.designation,
          unitThana: session.user.unitThana,
        };

        if (allowedTiers.length > 0 && !allowedTiers.includes(req.user.tier)) {
          return res.status(403).json({
            success: false,
            error: `Access denied. Requires clearance Tier ${allowedTiers.join('/')}. Current Tier: ${req.user.tier}.`,
          });
        }
        return next();
      }
    } catch (_) {
      // Fallback to Bearer token
    }

    // 2. Check Bearer token
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'Authentication required. Please sign in via BetterAuth or provide a valid Bearer token.',
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
      return res.status(403).json({
        success: false,
        error: `Access denied. Requires clearance Tier ${allowedTiers.join('/')}. Current Tier: ${req.user.tier}.`,
      });
    }
    return next();
  };
}

module.exports = { requireAuth, ROLE_TIERS, CLEARANCE_TIERS };
