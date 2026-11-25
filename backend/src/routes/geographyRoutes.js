const express = require('express');
const router = express.Router();
const geographyController = require('../controllers/geographyController');

router.get('/districts', geographyController.listDistricts);
router.get('/wards', geographyController.listWards);
router.get('/reverse-geocode', geographyController.reverseGeocode);

module.exports = router;
