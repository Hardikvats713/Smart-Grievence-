// Notification Service for in-app delivery and mobile push
const supabase = require('../config/supabase');
const { getStore, persist, generateId } = require('./localStore');

async function createNotification({ userId, userPhone, grievanceId, type, title, message }) {
  const notif = {
    id: generateId('notif'),
    user_id: userId,
    user_phone: userPhone,
    grievance_id: grievanceId || null,
    type,
    title,
    message,
    is_read: false,
    created_at: new Date().toISOString()
  };

  const store = getStore();
  if (store && store.notifications) {
    store.notifications.unshift(notif);
    persist();
  }

  if (supabase) {
    try {
      await supabase.from('notifications').insert([notif]);
    } catch (_) {
      // Non-blocking
    }
  }

  console.log(`[Notification Dispatched] ${type} to User ${userId || userPhone}: ${title}`);
  return notif;
}

module.exports = {
  createNotification
};
