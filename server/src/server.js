const { isProd, CORS_ORIGINS } = require('./config');
const express = require('express');
const cors = require('cors');
const apiRoutes = require('./routes/api');
const { securityHeaders } = require('./middleware/security');
const { auth } = require('./auth');
const { toNodeHandler } = require('better-auth/node');
const { checkConnection } = require('./db/db');

const app = express();
const PORT = process.env.PORT || 5050;

// Middleware
app.disable('x-powered-by');
app.use(securityHeaders);
// Development: any origin. Production: only the origins listed in CORS_ORIGIN.
app.use(cors({ origin: CORS_ORIGINS.length ? CORS_ORIGINS : !isProd, credentials: true }));

// Mount Better-Auth endpoints (Handles /api/auth/sign-in, sign-up, sign-out, session, etc.)
app.all('/api/auth/*', toNodeHandler(auth));

app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// Request Logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} ${res.statusCode} - ${duration}ms`);
  });
  next();
});

// Health check with PostgreSQL and BetterAuth status
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'CID Bangladesh Unidentified Deadbody Management System (UDBMS) API',
    version: '2.0.0',
    authSystem: 'BetterAuth (Tiered Clearance: Citizen, External IO, Forensic, CID, CIB Admin)',
    timestamp: new Date().toISOString(),
  });
});

// Mount API routes
app.use('/api/v1', apiRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: `Cannot ${req.method} ${req.path}. Endpoint not found.`,
  });
});

// Global Error Handler
app.use((err, req, res, next) => {
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ success: false, error: 'Malformed JSON body.' });
  }
  console.error('[API Error]:', err);
  res.status(500).json({
    success: false,
    error: 'Internal Server Error. Please contact CID Central Intelligence Bureau IT Wing.',
    details: isProd ? undefined : err.message,
  });
});

// Start Server & Check DB
checkConnection();
app.listen(PORT, () => {
  console.log(`================================================================`);
  console.log(` CID BANGLADESH - UDBMS FORENSIC API (BETTER-AUTH + POSTGRESQL) `);
  console.log(` Server running on http://localhost:${PORT}                      `);
  console.log(` BetterAuth at http://localhost:${PORT}/api/auth                `);
  console.log(` API Base at http://localhost:${PORT}/api/v1                    `);
  console.log(`================================================================`);
});
