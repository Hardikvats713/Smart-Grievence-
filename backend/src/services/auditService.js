// Structured Audit Logging Service
const supabase = require('../config/supabase');
const { getStore, persist, generateId } = require('./localStore');

async function logAuditEvent({ actorId, actorRole, action, entityType, entityId, req, payloadBefore, payloadAfter }) {
  const logEntry = {
    id: generateId('audit'),
    actor_id: actorId || null,
    actor_role: actorRole || 'ANONYMOUS',
    action,
    entity_type: entityType,
    entity_id: String(entityId),
    ip_address: req ? (req.headers['x-forwarded-for'] || req.socket.remoteAddress) : null,
    user_agent: req ? req.headers['user-agent'] : null,
    payload_before: payloadBefore || null,
    payload_after: payloadAfter || null,
    created_at: new Date().toISOString()
  };

  // Write to local store
  const store = getStore();
  if (store && store.audit_logs) {
    store.audit_logs.push(logEntry);
    persist();
  }

  // Attempt Supabase insert if available
  if (supabase) {
    try {
      await supabase.from('audit_logs').insert([logEntry]);
    } catch (_) {
      // Non-blocking
    }
  }

  return logEntry;
}

module.exports = {
  logAuditEvent
};
