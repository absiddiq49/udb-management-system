// Run with: npm test   (Node 20+, no extra test framework needed)
process.env.NODE_ENV = 'test';
const test = require('node:test');
const assert = require('node:assert');

const auth = require('../src/controllers/authController');
const pub = require('../src/controllers/publicController');
const requests = require('../src/controllers/requestController');
const official = require('../src/controllers/officialController');
const cross = require('../src/controllers/crossMatchController');
const { requireAuth } = require('../src/middleware/auth');
const { rateLimit } = require('../src/middleware/security');
require('../src/routes/api'); // fails loudly if any route points at a missing handler

function mockRes() {
  return {
    code: 200, body: null, headers: {},
    status(c) { this.code = c; return this; },
    json(b) { this.body = b; return this; },
    set(k, v) { this.headers[k] = v; return this; },
  };
}
const call = async (fn, req) => { const res = mockRes(); await fn({ ip: '1.1.1.1', headers: {}, body: {}, query: {}, params: {}, ...req }, res); return res; };

async function login(username, password = 'police123') {
  return call(auth.login, { body: { username, password } });
}

test('login: valid password works, wrong password / unknown user rejected', async () => {
  const ok = await login('cib_supervisor');
  assert.equal(ok.code, 200);
  assert.equal(ok.body.user.tier, 5);
  assert.equal((await login('cib_supervisor', 'wrong')).code, 401);
  assert.equal((await login('nobody', 'police123')).code, 401);
});

test('token login: demo pass works, random token does not', async () => {
  const ok = await call(auth.tokenLogin, { body: { token: 'cid-pass-7849-km' } });
  assert.equal(ok.code, 200);
  assert.equal(ok.body.user.role, 'external_io');
  assert.equal((await call(auth.tokenLogin, { body: { token: 'DEMO-IO-PASS' } })).code, 403);
});

test('requireAuth enforces clearance tiers', async () => {
  const io = (await call(auth.tokenLogin, { body: { token: 'CID-PASS-7849-KM' } })).body.token;
  const admin = (await login('cib_supervisor')).body.token;
  const run = async (token, tiers) => {
    const res = mockRes(); let passed = false;
    requireAuth(tiers)({ headers: { authorization: `Bearer ${token}` } }, res, () => { passed = true; });
    return { passed, code: res.code };
  };
  assert.equal((await run(io, [3, 4, 5])).code, 403);
  assert.equal((await run(admin, [3, 4, 5])).passed, true);
  assert.equal((await run('garbage', [1])).code, 401);
});

test('public API never leaks internal fields', async () => {
  const list = await call(pub.getCases, {});
  assert.ok(list.body.records.length > 0);
  const single = await call(pub.getCaseByRef, { params: { ref: list.body.records[0].referenceNo } });
  assert.equal(single.code, 200);
  for (const rec of [single.body.record, ...list.body.records]) {
    for (const secret of ['remarks', 'documents', 'postmortemReference', 'linkedForensicRecord', 'description']) {
      assert.ok(!(secret in rec), `${secret} leaked`);
    }
  }
  assert.equal((await call(pub.getCaseByRef, { params: { ref: 'nope' } })).code, 404);
  const cm = await call(cross.executeCrossMatch, { body: { gender: 'male', age: '30' } });
  assert.ok(cm.body.matches.every((m) => !('remarks' in m.record)));
});

test('IO request flow: approve once, token is restricted to its case', async () => {
  const submit = await call(requests.submitIoRequest, {
    body: { officerName: 'SI Test', bpNumber: 'BP-1', phone: '017', requestedCaseReference: 'CIB-UDB-2026-002' },
  });
  assert.equal(submit.code, 201);
  const code = submit.body.data.requestCode;
  const user = { fullName: 'SP Admin', bpNumber: 'BP-ADMIN', userId: 'a', tier: 5 };

  const approved = await call(requests.approveIoRequest, { params: { id: code }, user });
  assert.equal(approved.code, 200);
  assert.equal((await call(requests.approveIoRequest, { params: { id: code }, user })).code, 409);

  const token = approved.body.data.accessToken;
  const session = await call(auth.tokenLogin, { body: { token } });
  assert.equal(session.code, 200);
  const jwt = require('jsonwebtoken');
  const { JWT_SECRET } = require('../src/config');
  const io = jwt.verify(session.body.token, JWT_SECRET);

  const own = await call(official.getOfficialDossier, { params: { ref: 'CIB-UDB-2026-002' }, user: io });
  assert.equal(own.code, 200);
  const other = await call(official.getOfficialDossier, { params: { ref: 'CIB-UDB-2026-001' }, user: io });
  assert.equal(other.code, 403);
});

test('rate limiter returns 429 after the limit', () => {
  const limiter = rateLimit({ windowMs: 60000, max: 2 });
  const res = mockRes(); let passes = 0;
  for (let i = 0; i < 3; i++) limiter({ ip: '9.9.9.9' }, res, () => passes++);
  assert.equal(passes, 2);
  assert.equal(res.code, 429);
});
