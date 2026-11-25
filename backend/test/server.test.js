const test = require('node:test');
const assert = require('node:assert/strict');
const http = require('node:http');
const app = require('../src/app');

function request(server, method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const addr = server.address();
    const headers = { 'Content-Type': 'application/json' };
    if (token) headers['Authorization'] = `Bearer ${token}`;
    const options = {
      hostname: '127.0.0.1',
      port: addr.port,
      path,
      method,
      headers,
    };
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(data || '{}') }));
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

test('Smart Grievance API v1 Enterprise Test Suite', async (t) => {
  const server = app.listen(0);
  t.after(() => server.close());

  let citizenToken = '';
  let officerToken = '';
  let seniorOfficerToken = '';
  let createdGrievanceId = '';

  await t.test('1. GET /api/v1/health returns healthy envelope', async () => {
    const res = await request(server, 'GET', '/api/v1/health');
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.status, 'healthy');
    assert.equal(res.body.data.service, 'smart-grievance-backend');
  });

  await t.test('2. Auth: Citizen OTP login & Invalid OTP rejection', async () => {
    const badRes = await request(server, 'POST', '/api/v1/auth/verify-otp', {
      phoneNumber: '+919876543210',
      otp: '000000'
    });
    assert.equal(badRes.status, 401);
    assert.equal(badRes.body.success, false);

    const otpRes = await request(server, 'POST', '/api/v1/auth/send-otp', {
      phoneNumber: '+919876543210'
    });
    assert.equal(otpRes.status, 200);
    assert.equal(otpRes.body.success, true);

    const loginRes = await request(server, 'POST', '/api/v1/auth/verify-otp', {
      phoneNumber: '+919876543210',
      otp: '123456'
    });
    assert.equal(loginRes.status, 200);
    assert.equal(loginRes.body.success, true);
    assert.ok(loginRes.body.data.accessToken);
    assert.equal(loginRes.body.data.user.primaryRole, 'CITIZEN');
    citizenToken = loginRes.body.data.accessToken;
  });

  await t.test('3. Auth: Officer & Senior Officer OTP login', async () => {
    const offRes = await request(server, 'POST', '/api/v1/auth/verify-otp', {
      phoneNumber: '+919436000001',
      otp: '123456'
    });
    assert.equal(offRes.status, 200);
    assert.equal(offRes.body.data.user.primaryRole, 'DEPARTMENT_OFFICER');
    officerToken = offRes.body.data.accessToken;

    const snrRes = await request(server, 'POST', '/api/v1/auth/verify-otp', {
      phoneNumber: '+919436000003',
      otp: '123456'
    });
    assert.equal(snrRes.status, 200);
    assert.equal(snrRes.body.data.user.primaryRole, 'SENIOR_OFFICER');
    seniorOfficerToken = snrRes.body.data.accessToken;
  });

  await t.test('4. RBAC: Citizen blocked from Officer & Analytics routes (403)', async () => {
    const offQueueRes = await request(server, 'GET', '/api/v1/officer/grievances', null, citizenToken);
    assert.equal(offQueueRes.status, 403);
    assert.equal(offQueueRes.body.success, false);

    const analyticsRes = await request(server, 'GET', '/api/v1/analytics/overview', null, citizenToken);
    assert.equal(analyticsRes.status, 403);
    assert.equal(analyticsRes.body.success, false);
  });

  await t.test('5. Departments & Geography Master Data', async () => {
    const deptRes = await request(server, 'GET', '/api/v1/departments');
    assert.equal(deptRes.status, 200);
    assert.equal(deptRes.body.data.length, 7);

    const geoRes = await request(server, 'GET', '/api/v1/geography/reverse-geocode?lat=27.0984&lng=93.6288');
    assert.equal(geoRes.status, 200);
    assert.ok(geoRes.body.data.address.includes('Bank Tinali'));
  });

  await t.test('6. Grievance Submission & Lifecycle Transitions', async () => {
    const submitRes = await request(server, 'POST', '/api/v1/grievances', {
      categoryId: 'potholes',
      category: 'Roads',
      title: 'Collapsed culvert near Zero Point',
      description: 'Road culvert damaged after heavy rainfall',
      locationAddress: 'Zero Point, Itanagar',
      latitude: 27.1050,
      longitude: 93.6150,
      priority: 'HIGH'
    }, citizenToken);

    assert.equal(submitRes.status, 201);
    assert.equal(submitRes.body.success, true);
    assert.equal(submitRes.body.data.status, 'SUBMITTED');
    assert.ok(submitRes.body.data.sla_deadline);
    createdGrievanceId = submitRes.body.data.id;

    // Officer updates status: SUBMITTED -> IN_PROGRESS
    const progRes = await request(server, 'PATCH', `/api/v1/officer/grievances/${createdGrievanceId}/status`, {
      status: 'IN_PROGRESS',
      remarks: 'Engineering crew dispatched for site inspection'
    }, officerToken);
    assert.equal(progRes.status, 200);
    assert.equal(progRes.body.data.status, 'IN_PROGRESS');

    // Officer adds internal remark
    const remarkRes = await request(server, 'POST', `/api/v1/officer/grievances/${createdGrievanceId}/remarks`, {
      remark: 'Requires 2 bags of cement and drainage pipe',
      isInternal: true
    }, officerToken);
    assert.equal(remarkRes.status, 201);

    // Officer resolves grievance: IN_PROGRESS -> RESOLVED
    const resolveRes = await request(server, 'PATCH', `/api/v1/officer/grievances/${createdGrievanceId}/status`, {
      status: 'RESOLVED',
      remarks: 'Culvert repaired and road cleared'
    }, officerToken);
    assert.equal(resolveRes.status, 200);
    assert.equal(resolveRes.body.data.status, 'RESOLVED');

    // Illegal transition: RESOLVED -> SUBMITTED should fail with 422
    const illegalRes = await request(server, 'PATCH', `/api/v1/officer/grievances/${createdGrievanceId}/status`, {
      status: 'SUBMITTED'
    }, officerToken);
    assert.equal(illegalRes.status, 422);

    // Citizen submits feedback -> CLOSED
    const fbRes = await request(server, 'POST', `/api/v1/grievances/${createdGrievanceId}/feedback`, {
      rating: 5,
      comments: 'Quick response by PWD!'
    }, citizenToken);
    assert.equal(fbRes.status, 200);
    assert.equal(fbRes.body.data.rating, 5);
  });

  await t.test('7. Analytics Overview accessible to Senior Officer', async () => {
    const res = await request(server, 'GET', '/api/v1/analytics/overview', null, seniorOfficerToken);
    assert.equal(res.status, 200);
    assert.ok(res.body.data.summary.totalGrievances >= 2);
  });
});
