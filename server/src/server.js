require('dotenv').config();
const express = require('express');
const cors = require('cors');
const apiRoutes = require('./routes/api');

const app = express();
const PORT = process.env.PORT || 5050;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Request Logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} ${res.statusCode} - ${duration}ms`);
  });
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'CID Bangladesh Unidentified Dead Body Management API',
    version: '1.0.0',
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
  console.error('[API Error]:', err);
  res.status(500).json({
    success: false,
    error: 'Internal Server Error. Please contact CID Central Intelligence Bureau IT Wing.',
    details: process.env.NODE_ENV === 'production' ? undefined : err.message,
  });
});

// Start Server
app.listen(PORT, () => {
  console.log(`================================================================`);
  console.log(` CID BANGLADESH - UNIDENTIFIED DEAD BODY MANAGEMENT SYSTEM API `);
  console.log(` Server running on http://localhost:${PORT}                      `);
  console.log(` Health check at http://localhost:${PORT}/health                `);
  console.log(` API Base at http://localhost:${PORT}/api/v1                    `);
  console.log(`================================================================`);
});

