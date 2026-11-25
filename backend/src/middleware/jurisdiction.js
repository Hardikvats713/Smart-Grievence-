// Department and Geographical Jurisdiction Boundary Enforcement Guard
const { ROLES } = require('../config/constants');

function requireJurisdictionBoundary(options = {}) {
  return function(req, res, next) {
    const user = req.user;
    if (!user) {
      return res.fail('Authentication required', 401);
    }

    // Administrators bypass localized departmental jurisdiction boundaries
    if (user.activeRole === ROLES.ADMINISTRATOR || (user.roles && user.roles.includes(ROLES.ADMINISTRATOR))) {
      return next();
    }

    // Senior officers have district-wide jurisdiction
    if (user.activeRole === ROLES.SENIOR_OFFICER) {
      req.jurisdictionFilter = {
        districtId: user.districtId,
        departmentId: user.departmentId || null
      };
      return next();
    }

    // Field Department Officers are strictly bounded by Department + Jurisdiction
    if (user.activeRole === ROLES.DEPARTMENT_OFFICER) {
      req.jurisdictionFilter = {
        departmentId: user.departmentId,
        jurisdictionId: user.jurisdictionId,
        districtId: user.districtId
      };
      return next();
    }

    // Citizens are filtered strictly by their own user ID
    if (user.activeRole === ROLES.CITIZEN) {
      req.jurisdictionFilter = {
        citizenId: user.sub || user.id
      };
      return next();
    }

    next();
  };
}

module.exports = {
  requireJurisdictionBoundary
};
