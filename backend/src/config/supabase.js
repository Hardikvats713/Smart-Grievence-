const { createClient } = require('@supabase/supabase-js');
const config = require('./env');

let supabase = null;

if (config.SUPABASE_URL && config.SUPABASE_KEY) {
  try {
    supabase = createClient(config.SUPABASE_URL, config.SUPABASE_KEY, {
      auth: { persistSession: false }
    });
    console.log('[Supabase] Initialized client for:', config.SUPABASE_URL);
  } catch (err) {
    console.error('[Supabase] Initialization error:', err.message);
    supabase = null;
  }
} else {
  console.warn('[Supabase] URL or Key missing. Running in local memory/file fallback mode.');
}

module.exports = supabase;
