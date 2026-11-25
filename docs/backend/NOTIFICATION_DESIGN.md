# Multi-Channel Notification Architecture
## Smart Grievance Management Information System — Arunachal Pradesh

### 1. Notification Event Triggers & Channels
Civic governance requires timely communication to both citizens and field officers across multiple delivery channels.

| Event Key | Target Audience | Primary Channel | Secondary Channel | Message Template |
|---|---|---|---|---|
| `GRIEVANCE_SUBMITTED` | Citizen | FCM Push + In-App | SMS | "Your grievance #{ref} has been registered successfully." |
| `OFFICER_ASSIGNED` | Department Officer | FCM Push + In-App | SMS | "New grievance #{ref} assigned to your jurisdiction ({ward})." |
| `STATUS_IN_PROGRESS` | Citizen | FCM Push + In-App | - | "Investigation started on #{ref} by {department}." |
| `FIELD_INSPECTION_SCHEDULED` | Citizen | FCM Push + In-App | SMS | "Site inspection for #{ref} scheduled on {date}." |
| `RESOLUTION_PROPOSED` | Senior Officer | In-App + FCM Push | - | "Resolution proposed for #{ref}. Pending your approval." |
| `GRIEVANCE_RESOLVED` | Citizen | FCM Push + In-App | SMS | "Grievance #{ref} resolved! Tap here to review proof and submit feedback." |
| `SLA_WARNING_L1` | Field Officer | FCM Push + In-App | High-Priority SMS | "Warning: Grievance #{ref} has reached 75% of SLA deadline." |
| `SLA_BREACH_L2` | Senior Officer | FCM Push + In-App | Email Alert | "ESCALATION: Grievance #{ref} breached SLA. Reassigned to supervisory review." |

---

### 2. Notification Persistence Schema
All notifications are recorded in `public.notifications`:
```sql
CREATE TABLE public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  grievance_id uuid REFERENCES public.grievances(id) ON DELETE CASCADE,
  type varchar(50) NOT NULL,
  title varchar(150) NOT NULL,
  message text NOT NULL,
  is_read boolean NOT NULL DEFAULT false,
  read_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);
```

### 3. Firebase Cloud Messaging (FCM) Integration
When a state transition occurs, the backend triggers FCM notification dispatch to the user's registered device tokens. In development or offline mode, in-app notification records are immediately viewable via `GET /api/v1/notifications`.
