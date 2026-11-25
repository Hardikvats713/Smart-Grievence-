const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analyticsController');
const { authenticateToken } = require('../middleware/auth');
const { requireAnyRole } = require('../middleware/rbac');
const { ROLES } = require('../config/constants');

router.get(
  '/overview',
  authenticateToken,
  requireAnyRole([ROLES.DEPARTMENT_OFFICER, ROLES.SENIOR_OFFICER, ROLES.ADMINISTRATOR]),
  analyticsController.getOverview
);

module.exports = router;
