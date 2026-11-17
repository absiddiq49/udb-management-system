const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'cid_bangladesh_secret_key_2026_udb';

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

      if (allowedTiers.length > 0 && !allowedTiers.includes(decoded.tier)) {
        return res.status(403).json({
          success: false,
          error: `Access denied. Requires one of clearance tiers: ${allowedTiers.join(', ')}. Your tier: ${decoded.tier}`,
        });
      }

      next();
    } catch (err) {
      return res.status(401).json({
        success: false,
        error: 'Invalid or expired session token. Please re-authenticate.',
      });
    }
  };
}

module.exports = {
  requireAuth,
  JWT_SECRET,
};

