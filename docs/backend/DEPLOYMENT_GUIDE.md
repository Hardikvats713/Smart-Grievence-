# Deployment, Environment & Configuration Guide
## Smart Grievance Management Information System — Arunachal Pradesh

### 1. Prerequisites & Environment Setup
- **Node.js:** v18.0.0 or v20.x LTS
- **Package Manager:** npm v9+
- **Database:** Supabase PostgreSQL with PostGIS extension enabled
- **Flutter SDK:** 3.19+ (Dart 3.3+)
- **Mobile Target:** Android (API 26+) & iOS (14+)

---

### 2. Environment Variables Configuration (`backend/.env`)

```ini
# Server Configuration
PORT=3000
NODE_ENV=production
API_PREFIX=/api/v1

# Security & Tokens
JWT_ACCESS_SECRET=your_hyper_secure_256_bit_jwt_secret_key_here
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_SECRET=your_hyper_secure_256_bit_refresh_secret_key_here
JWT_REFRESH_EXPIRY=30d

# Supabase Credentials (Managed PostgreSQL + Storage)
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=<YOUR_SUPABASE_PUBLISHABLE_KEY>
SUPABASE_SERVICE_ROLE_KEY=<YOUR_SUPABASE_SECRET_KEY>

# Storage Bucket Names
SUPABASE_BUCKET_EVIDENCE=grievance-evidence
SUPABASE_BUCKET_RESOLUTIONS=resolution-proof
SUPABASE_BUCKET_AVATARS=avatars

# External Maps & Location APIs
GOOGLE_MAPS_API_KEY=<YOUR_GOOGLE_MAPS_API_KEY>
NOMINATIM_USER_AGENT=SmartGrievanceArunachal/1.0

# CORS Allowed Origins
CORS_ORIGIN=*
```

---

### 3. Database Migration Execution Instructions
1. Log in to the [Supabase Dashboard](https://supabase.com/dashboard) and open project `ekynfsyiniwlhrgiytdr`.
2. Navigate to the **SQL Editor** in the left sidebar.
3. Open or paste the contents of `backend/supabase/full_schema.sql` (or the migration scripts in `backend/supabase/migrations/`).
4. Click **Run** to execute the DDL queries, enabling PostGIS, creating all tables, foreign keys, spatial indexes, and seeding default departments, roles, and administrative areas.
5. Create the required private storage buckets:
   - `grievance-evidence` (Private)
   - `resolution-proof` (Private)
   - `avatars` (Public)

---

### 4. Running Backend Service
```bash
# In backend directory
cd backend
npm install
npm run start

# Running in background via PM2 or Systemd
pm2 start src/server.js --name "smart-grievance-api"
```

Verify service health:
```bash
curl http://localhost:3000/api/v1/health
```
Expected response:
```json
{
  "success": true,
  "message": "Smart Grievance API v1 is operational",
  "data": {
    "status": "healthy",
    "version": "1.0.0",
    "environment": "production",
    "timestamp": "2026-11-25T08:00:00.000Z"
  }
}
```
