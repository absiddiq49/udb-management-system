const store = require('../db/store');

const MAX_ENTRIES = 5000;

// Appends an audit entry. `actor` is only needed when req.user is not set (e.g. login).
function log(req, action, reference = null, actor = null) {
  const who = actor || req.user || {};
  store.auditLogs.unshift({
    at: new Date().toISOString(),
    action,
    reference,
    userId: who.userId || null,
    bpNumber: who.bpNumber || null,
    role: who.role || null,
    ip: req.ip || null,
  });
  if (store.auditLogs.length > MAX_ENTRIES) store.auditLogs.length = MAX_ENTRIES;
}

module.exports = { log };
