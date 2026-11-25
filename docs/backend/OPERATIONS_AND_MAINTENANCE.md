# Operations, Monitoring & Maintenance Runbook
## Smart Grievance Management Information System — Arunachal Pradesh

### 1. Daily Operations & Routine Maintenance
- **Database Backup Verification:** Ensure Supabase automated daily backups complete without warnings.
- **SLA Breach Monitoring:** Query `escalation_records` daily at 09:00 AM to report overdue complaints to Section Officers.
- **Storage Cleanup:** Prune orphaned uploaded files older than 48 hours that were not bound to any submitted grievance record.

---

### 2. Health Monitoring & Alerting
- **Endpoint:** `GET /api/v1/health`
  - Evaluates: Express server status, PostgreSQL database connection latency, Supabase storage bucket responsiveness.
- **Logging:** Structured JSON logs emitted to stdout/stderr with correlation IDs for all inbound API requests.
- **Metrics:** Request rate, error rate (5xx), latency percentiles (P95, P99).

---

### 3. Incident Response Playbook
- **Database Connection Pool Exhaustion:**
  - Increase Supabase connection pool size or activate Supabase Transaction Pooler (PgBouncer) on port 6543.
- **Mass Emergency Event (e.g., Heavy Rain / Landslide):**
  - Temporarily extend SLA window for road clearing departments via `UPDATE public.sla_policies SET target_resolution_hours = 120 WHERE department_id = (SELECT id FROM departments WHERE department_code = 'ROADS');`
