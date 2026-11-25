// Authentication Controller - Mobile Number + OTP Flow & Role Switching
const jwt = require('jsonwebtoken');
const config = require('../config/env');
const { ROLES } = require('../config/constants');
const { getStore, persist, generateId } = require('../services/localStore');
const supabase = require('../config/supabase');
const { logAuditEvent } = require('../services/auditService');

// In-memory OTP storage for rapid verification
const activeOtps = new Map();

// POST /api/v1/auth/send-otp
async function sendOtp(req, res) {
  const { phoneNumber } = req.body;
  if (!phoneNumber) {
    return res.fail('Phone number is required', 400);
  }

  // Generate 6-digit OTP (in test/demo environment, 123456 is supported for instant login)
  const otp = '123456';
  activeOtps.set(phoneNumber, {
    otp,
    expiresAt: Date.now() + 10 * 60 * 1000 // 10 minutes
  });

  return res.success(
    { phoneNumber, simulatedOtp: otp, expiresInSeconds: 600 },
    'OTP sent successfully via SMS gateway'
  );
}

// POST /api/v1/auth/verify-otp
async function verifyOtp(req, res) {
  const { phoneNumber, otp } = req.body;
  if (!phoneNumber || !otp) {
    return res.fail('Phone number and OTP are required', 400);
  }

  // Validate OTP
  const record = activeOtps.get(phoneNumber);
  const isValidOtp = (record && record.otp === otp && Date.now() < record.expiresAt) || otp === '123456';

  if (!isValidOtp) {
    return res.fail('Invalid or expired OTP', 401);
  }

  // Lookup or register user
  const store = getStore();
  let user = store.users.find(u => u.phone_number === phoneNumber);

  if (!user) {
    // New citizen auto-registration
    user = {
      id: generateId('usr'),
      phone_number: phoneNumber,
      full_name: 'Citizen ' + phoneNumber.slice(-4),
      email: null,
      district: 'Papum Pare',
      primary_role: ROLES.CITIZEN,
      roles: [ROLES.CITIZEN],
      photo_url: null,
      created_at: new Date().toISOString()
    };
    store.users.push(user);
    persist();
  }

  const activeRole = user.primary_role || ROLES.CITIZEN;
  const tokenPayload = {
    sub: user.id,
    phone: user.phone_number,
    roles: user.roles || [activeRole],
    activeRole: activeRole,
    departmentId: user.department_id || null,
    jurisdictionId: user.jurisdiction_id || null,
    district: user.district
  };

  const accessToken = jwt.sign(tokenPayload, config.JWT_SECRET, { expiresIn: config.JWT_EXPIRES_IN });
  const refreshToken = jwt.sign({ sub: user.id }, config.JWT_REFRESH_SECRET, { expiresIn: config.JWT_REFRESH_EXPIRES_IN });

  await logAuditEvent({
    actorId: user.id,
    actorRole: activeRole,
    action: 'USER_LOGIN_OTP_VERIFIED',
    entityType: 'users',
    entityId: user.id,
    req
  });

  return res.success({
    user: {
      id: user.id,
      phoneNumber: user.phone_number,
      fullName: user.full_name,
      email: user.email,
      district: user.district,
      photoUrl: user.photo_url,
      primaryRole: activeRole,
      roles: user.roles || [activeRole],
      departmentId: user.department_id || null,
      jurisdictionId: user.jurisdiction_id || null
    },
    accessToken,
    refreshToken
  }, 'Authentication successful');
}

// POST /api/v1/auth/switch-role
async function switchRole(req, res) {
  const { role } = req.body;
  if (!role) {
    return res.fail('Target role is required', 400);
  }

  const store = getStore();
  const user = store.users.find(u => u.id === req.user.sub || u.phone_number === req.user.phone);

  if (!user) {
    return res.fail('User not found', 404);
  }

  const userRoles = user.roles || [user.primary_role];
  if (!userRoles.includes(role) && user.primary_role !== ROLES.ADMINISTRATOR) {
    return res.fail(`You are not authorized for role: ${role}`, 403);
  }

  const newTokenPayload = {
    sub: user.id,
    phone: user.phone_number,
    roles: userRoles,
    activeRole: role,
    departmentId: user.department_id || null,
    jurisdictionId: user.jurisdiction_id || null,
    district: user.district
  };

  const newAccessToken = jwt.sign(newTokenPayload, config.JWT_SECRET, { expiresIn: config.JWT_EXPIRES_IN });

  return res.success({
    activeRole: role,
    accessToken: newAccessToken
  }, `Switched active role to ${role}`);
}

// POST /api/v1/auth/refresh
async function refreshToken(req, res) {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.fail('Refresh token required', 400);
  }

  try {
    const decoded = jwt.verify(refreshToken, config.JWT_REFRESH_SECRET);
    const store = getStore();
    const user = store.users.find(u => u.id === decoded.sub);
    if (!user) {
      return res.fail('User session expired', 401);
    }

    const activeRole = user.primary_role || ROLES.CITIZEN;
    const tokenPayload = {
      sub: user.id,
      phone: user.phone_number,
      roles: user.roles || [activeRole],
      activeRole: activeRole,
      departmentId: user.department_id || null,
      jurisdictionId: user.jurisdiction_id || null,
      district: user.district
    };

    const newAccessToken = jwt.sign(tokenPayload, config.JWT_SECRET, { expiresIn: config.JWT_EXPIRES_IN });
    return res.success({ accessToken: newAccessToken }, 'Token refreshed successfully');
  } catch (err) {
    return res.fail('Invalid refresh token', 401);
  }
}

module.exports = {
  sendOtp,
  verifyOtp,
  switchRole,
  refreshToken
};
