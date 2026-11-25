const express = require('express');
const router = express.Router();
const grievanceController = require('../controllers/grievanceController');
const { authenticateToken, optionalAuth } = require('../middleware/auth');

router.get('/', optionalAuth, grievanceController.listGrievances);
router.get('/:id', optionalAuth, grievanceController.getGrievanceById);
router.post('/', optionalAuth, grievanceController.submitGrievance);
router.post('/:id/feedback', optionalAuth, grievanceController.submitFeedback);
router.post('/:id/reopen', optionalAuth, grievanceController.requestReopen);

module.exports = router;
