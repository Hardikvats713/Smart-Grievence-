// Role-based Access Control (RBAC) middleware
const { ROLES } = require('../config/constants');

function requireRole(role) {
  return function(req, res, next) {
    if (!req.user) {
      return res.fail('Authentication required', 401);
    }

    const activeRole = req.user.activeRole || req.user.primaryRole || req.user.role || ROLES.CITIZEN;
    const userRoles = req.user.roles || [activeRole];

    if (activeRole === role || userRoles.includes(role) || activeRole === ROLES.ADMINISTRATOR) {
      return next();
    }

    return res.fail(`Access denied. Requires role: ${role}`, 403, {
      requiredRole: role,
      currentRole: activeRole
    });
  };
}

function requireAnyRole(allowedRoles = []) {
  return function(req, res, next) {
    if (!req.user) {
      return res.fail('Authentication required', 401);
    }

    const activeRole = req.user.activeRole || req.user.primaryRole || req.user.role || ROLES.CITIZEN;
    const userRoles = req.user.roles || [activeRole];

    const hasAccess = allowedRoles.some(r => r === activeRole || userRoles.includes(r)) || activeRole === ROLES.ADMINISTRATOR;

    if (hasAccess) {
      return next();
    }

    return res.fail(`Access denied. Requires one of: ${allowedRoles.join(', ')}`, 403, {
      allowedRoles,
      currentRole: activeRole
    });
  };
}

module.exports = {
  requireRole,
  requireAnyRole
};
