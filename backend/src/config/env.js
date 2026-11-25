require('dotenv').config();

module.exports = {
  PORT: process.env.PORT || 3000,
  NODE_ENV: process.env.NODE_ENV || 'development',
  JWT_SECRET: process.env.JWT_ACCESS_SECRET || process.env.JWT_SECRET || 'smart-grievance-dev-jwt-secret-key-32chars-min',
  JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET || 'smart-grievance-dev-refresh-secret-key-32chars',
  JWT_EXPIRES_IN: process.env.JWT_ACCESS_EXPIRY || '15m',
  JWT_REFRESH_EXPIRES_IN: process.env.JWT_REFRESH_EXPIRY || '30d',

  SUPABASE_URL: (process.env.SUPABASE_URL || '').trim(),
  SUPABASE_KEY: (process.env.SUPABASE_SECRET_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_PUBLISHABLE_KEY || '').trim(),
  
  BUCKETS: {
    EVIDENCE: process.env.SUPABASE_BUCKET_EVIDENCE || 'grievance-evidence',
    RESOLUTIONS: process.env.SUPABASE_BUCKET_RESOLUTIONS || 'resolution-proof',
    AVATARS: process.env.SUPABASE_BUCKET_AVATARS || 'avatars'
  }
};
