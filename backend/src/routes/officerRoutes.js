const express = require('express');
const router = express.Router();
const officerController = require('../controllers/officerController');
const { authenticateToken } = require('../middleware/auth');
const { requireAnyRole } = require('../middleware/rbac');
const { requireJurisdictionBoundary } = require('../middleware/jurisdiction');
const { ROLES } = require('../config/constants');

const officerAccess = [
  authenticateToken,
  requireAnyRole([ROLES.DEPARTMENT_OFFICER, ROLES.SENIOR_OFFICER, ROLES.ADMINISTRATOR]),
  requireJurisdictionBoundary()
];

router.get('/grievances', officerAccess, officerController.getOfficerQueue);
router.patch('/grievances/:id/status', officerAccess, officerController.updateGrievanceStatus);
router.post('/grievances/:id/remarks', officerAccess, officerController.addInvestigationRemark);

module.exports = router;
