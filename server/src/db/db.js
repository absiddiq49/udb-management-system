const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.PG_HOST || 'localhost',
  port: parseInt(process.env.PG_PORT || '5432'),
  user: process.env.PG_USER || 'postgres',
  password: process.env.PG_PASSWORD || 'postgres',
  database: process.env.PG_DATABASE || 'cid_udb_db',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

let isPgConnected = false;

async function checkConnection() {
  try {
    const client = await pool.connect();
    isPgConnected = true;
    client.release();
    console.log('[PostgreSQL] Connected successfully to database');
  } catch (err) {
    isPgConnected = false;
    console.warn('[PostgreSQL] Database not reachable. Server operating in fallback mode:', err.message);
  }
}

module.exports = {
  pool,
  query: (text, params) => pool.query(text, params),
  isPgConnected: () => isPgConnected,
  checkConnection,
};

