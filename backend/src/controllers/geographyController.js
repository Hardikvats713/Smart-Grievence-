// Geography and Jurisdiction Controller (Districts, Wards, Reverse Geocoding)
const { getStore } = require('../services/localStore');

// GET /api/v1/geography/districts
async function listDistricts(req, res) {
  const store = getStore();
  return res.success(store.districts, 'Districts retrieved');
}

// GET /api/v1/geography/wards
async function listWards(req, res) {
  const store = getStore();
  const { districtId } = req.query;

  let wards = store.wards;
  if (districtId) {
    wards = wards.filter(w => w.district_id === districtId);
  }

  return res.success(wards, 'Wards retrieved');
}

// GET /api/v1/geography/reverse-geocode
async function reverseGeocode(req, res) {
  const { lat, lng } = req.query;
  if (!lat || !lng) {
    return res.fail('Latitude and longitude are required', 400);
  }

  // Realistic Arunachal Pradesh reverse geocode mapping based on coordinates
  const latitude = parseFloat(lat);
  const longitude = parseFloat(lng);

  let address = 'Itanagar, Papum Pare, Arunachal Pradesh';
  let district = 'Papum Pare';
  let ward = 'Ward 02 - Bank Tinali';

  if (Math.abs(latitude - 27.0984) < 0.02 && Math.abs(longitude - 93.6288) < 0.02) {
    address = 'Bank Tinali, VIP Road, Itanagar, Arunachal Pradesh 791111';
    ward = 'Ward 02 - Bank Tinali';
  } else if (Math.abs(latitude - 27.1025) < 0.03) {
    address = 'Ganga Market, NH-415, Itanagar, Arunachal Pradesh 791113';
    ward = 'Ward 01 - Ganga / Chimpu';
  }

  return res.success({
    latitude,
    longitude,
    address,
    district,
    ward,
    state: 'Arunachal Pradesh'
  }, 'Reverse geocoded location');
}

module.exports = {
  listDistricts,
  listWards,
  reverseGeocode
};
