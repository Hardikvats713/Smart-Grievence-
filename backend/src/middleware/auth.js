const jwt = require('jsonwebtoken');
const config = require('../config/env');

// Authenticates JWT access tokens and injects verified user identity into req.user
function authenticateToken(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.fail('Authorization token missing or malformed', 401);
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, config.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.fail('Session token expired. Please refresh or re-login.', 401, { code: 'TOKEN_EXPIRED' });
    }
    return res.fail('Invalid authentication token', 401, { code: 'TOKEN_INVALID' });
  }
}

// Optional authentication - populates req.user if token is valid, but does not reject if absent
function optionalAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1];
    try {
      req.user = jwt.verify(token, config.JWT_SECRET);
    } catch (_) {
      req.user = null;
    }
  }
  next();
}

module.exports = {
  authenticateToken,
  optionalAuth
};
