const express = require('express');
const router = express.Router();
const { getStore, persist } = require('../services/localStore');
const { optionalAuth } = require('../middleware/auth');

// GET /api/v1/notifications
router.get('/', optionalAuth, (req, res) => {
  const store = getStore();
  let list = [...store.notifications];
  if (req.user) {
    list = list.filter(n => n.user_id === req.user.sub || n.user_phone === req.user.phone || !n.user_id);
  }
  return res.success(list, 'Notifications retrieved');
});

// PATCH /api/v1/notifications/:id/read
router.patch('/:id/read', optionalAuth, (req, res) => {
  const store = getStore();
  const notif = store.notifications.find(n => n.id === req.params.id);
  if (!notif) return res.fail('Notification not found', 404);
  notif.is_read = true;
  notif.read_at = new Date().toISOString();
  persist();
  return res.success(notif, 'Notification marked as read');
});

module.exports = router;
