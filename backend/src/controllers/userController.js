// User and Citizen Profile Controller
const { getStore, persist } = require('../services/localStore');
const supabase = require('../config/supabase');

// GET /api/v1/users/profile
async function getProfile(req, res) {
  const store = getStore();
  const userId = req.user.sub;
  const user = store.users.find(u => u.id === userId || u.phone_number === req.user.phone);

  if (!user) {
    return res.fail('User not found', 404);
  }

  return res.success({
    id: user.id,
    phoneNumber: user.phone_number,
    fullName: user.full_name,
    email: user.email,
    district: user.district,
    photoUrl: user.photo_url,
    primaryRole: user.primary_role,
    roles: user.roles || [user.primary_role]
  }, 'Profile retrieved');
}

// PUT /api/v1/users/profile
async function updateProfile(req, res) {
  const store = getStore();
  const userId = req.user.sub;
  const user = store.users.find(u => u.id === userId || u.phone_number === req.user.phone);

  if (!user) {
    return res.fail('User not found', 404);
  }

  const { fullName, email, district, photoUrl } = req.body;
  if (fullName) user.full_name = fullName;
  if (email !== undefined) user.email = email;
  if (district) user.district = district;
  if (photoUrl !== undefined) user.photo_url = photoUrl;
  user.updated_at = new Date().toISOString();

  persist();

  // Update in Supabase if table exists
  if (supabase) {
    try {
      await supabase.from('profiles').upsert({
        phone_number: user.phone_number,
        full_name: user.full_name,
        email: user.email,
        district: user.district,
        photo_base64: user.photo_url,
        updated_at: user.updated_at
      });
    } catch (_) {}
  }

  return res.success({
    id: user.id,
    phoneNumber: user.phone_number,
    fullName: user.full_name,
    email: user.email,
    district: user.district,
    photoUrl: user.photo_url
  }, 'Profile updated successfully');
}

module.exports = {
  getProfile,
  updateProfile
};
