# Media Evidence & Private Storage Architecture
## Smart Grievance Management Information System — Arunachal Pradesh

### 1. Storage Architecture Overview
All uploaded citizen evidence, officer site surveys, and resolution proofs are stored in private Supabase Storage buckets. Direct public read access is forbidden.

```mermaid
sequenceDiagram
    participant User as Flutter App (Citizen / Officer)
    participant API as Express API Server
    participant Storage as Supabase Private Storage Bucket

    User->>API: 1. Request Upload URL (file name, MIME, size)
    API->>API: 2. Validate MIME (image/jpeg, png, mp4) & Size (<= 15MB)
    API->>Storage: 3. Create Presigned Upload Path
    API-->>User: 4. Return Presigned Upload URL & File Key
    User->>Storage: 5. Direct PUT upload to storage
    User->>API: 6. Confirm attachment metadata & bind to Grievance ID
    
    Note over User,Storage: Viewing Evidence (Signed URL)
    User->>API: 7. GET /api/v1/grievances/:id/attachments
    API->>API: 8. Verify User Authorization (Owner Citizen OR Authorized Officer)
    API->>Storage: 9. Generate Signed Read URL (valid 15 minutes)
    API-->>User: 10. Return Attachment list with signed URLs
```

---

### 2. Bucket Organization & Quotas
- **Bucket: `grievance-evidence` (Private)**
  - Path pattern: `{grievance_id}/{attachment_type}_{timestamp}_{random}.{ext}`
  - Example: `b1a2c3d4/CITIZEN_EVIDENCE_1732525200_a9f1.jpg`
  - Max file size: 10 MB per image, 25 MB per video. Max 5 attachments per grievance.
- **Bucket: `resolution-proof` (Private)**
  - Path pattern: `{grievance_id}/RESOLUTION_PROOF_{timestamp}_{random}.{ext}`
  - Strictly officer-uploaded visual proof of repaired public asset.
- **Bucket: `avatars` (Public/Private CDN)**
  - User profile pictures. Max file size: 2 MB. Allowed types: `image/jpeg`, `image/png`.

---

### 3. Signed URL Expiration Policy
- All temporary read URLs generated via `@supabase/supabase-js` `createSignedUrl` expire after **900 seconds (15 minutes)**.
- Flutter mobile app caches loaded images in local memory/cache directory (`cached_network_image`) to avoid re-requesting signatures unnecessarily while browsing within the same session.
