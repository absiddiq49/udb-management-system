const crypto = require('crypto');
require('dotenv').config();

const isProd = process.env.NODE_ENV === 'production';

let jwtSecret = process.env.JWT_SECRET;
if (!jwtSecret || jwtSecret.startsWith('change-me')) {
  if (isProd) {
    throw new Error('JWT_SECRET must be set to a long random value when NODE_ENV=production.');
  }
  jwtSecret = crypto.randomBytes(48).toString('hex');
  console.warn('[config] JWT_SECRET not set: using a random secret for this run (tokens reset on restart).');
}

module.exports = {
  isProd,
  JWT_SECRET: jwtSecret,
  // Comma separated list of allowed browser origins, e.g. https://udb.example.gov.bd
  CORS_ORIGINS: (process.env.CORS_ORIGIN || '').split(',').map((s) => s.trim()).filter(Boolean),
};
