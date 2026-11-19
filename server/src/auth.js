const { betterAuth } = require('better-auth');
const { pool } = require('./db/db');

// Tiered clearance definitions for Bangladesh Police & Law Enforcement
const CLEARANCE_TIERS = {
  PUBLIC_CITIZEN: 0,
  EXTERNAL_IO: 1,      // Thana Sub-Inspectors / Station IOs (72-hour pass)
  FORENSIC_EXPERT: 2,  // Medical Doctors, DNA Profiling Specialists, Autopsy Surgeons
  CID_OFFICER: 3,      // Central Intelligence Bureau & Homicide Squad Officers
  CIB_ADMIN: 5,        // Super Admin & Special Superintendent of Police (SP)
};

const auth = betterAuth({
  database: pool,
  secret: process.env.BETTER_AUTH_SECRET || process.env.JWT_SECRET || 'bangladesh-cid-udbms-better-auth-secret-key-32ch',
  baseURL: process.env.BETTER_AUTH_URL || 'http://localhost:5050',
  basePath: '/api/auth',
  emailAndPassword: {
    enabled: true,
    autoSignIn: true,
  },
  user: {
    additionalFields: {
      role: {
        type: 'string',
        required: false,
        defaultValue: 'citizen',
      },
      tier: {
        type: 'number',
        required: false,
        defaultValue: 0,
      },
      bpNumber: {
        type: 'string',
        required: false,
      },
      rank: {
        type: 'string',
        required: false,
      },
      designation: {
        type: 'string',
        required: false,
      },
      unitThana: {
        type: 'string',
        required: false,
      },
      phoneNumber: {
        type: 'string',
        required: false,
      },
      isActive: {
        type: 'boolean',
        required: false,
        defaultValue: true,
      },
    },
  },
  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7 days
    updateAge: 60 * 60 * 24, // 1 day
  },
});

module.exports = {
  auth,
  CLEARANCE_TIERS,
};
