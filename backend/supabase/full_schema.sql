-- ============================================================================
-- SMART GRIEVANCE (ARUNACHAL PRADESH) - COMPLETE CONSOLIDATED SQL SCHEMA & SEEDS
-- File: backend/supabase/full_schema.sql
-- ============================================================================

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- 2. Core Security & Identity Tables
CREATE TABLE IF NOT EXISTS public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    photo_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    primary_role VARCHAR(50) NOT NULL DEFAULT 'CITIZEN',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_roles (
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES public.users(id),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS public.user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    refresh_token_hash TEXT NOT NULL,
    device_info TEXT,
    ip_address INET,
    is_revoked BOOLEAN NOT NULL DEFAULT false,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Geographical Hierarchy & Spatial Entities
CREATE TABLE IF NOT EXISTS public.states (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    state_code VARCHAR(10) UNIQUE NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.districts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    state_id UUID NOT NULL REFERENCES public.states(id) ON DELETE CASCADE,
    district_code VARCHAR(50) UNIQUE NOT NULL,
    district_name VARCHAR(100) NOT NULL,
    headquarters VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.administrative_areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    district_id UUID NOT NULL REFERENCES public.districts(id) ON DELETE CASCADE,
    area_name VARCHAR(100) NOT NULL,
    area_type VARCHAR(50) NOT NULL DEFAULT 'WARD',
    boundary_polygon GEOGRAPHY(Polygon, 4326),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.jurisdictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    district_id UUID NOT NULL REFERENCES public.districts(id) ON DELETE CASCADE,
    administrative_area_id UUID REFERENCES public.administrative_areas(id) ON DELETE SET NULL,
    boundary GEOGRAPHY(MultiPolygon, 4326),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Department & Category Routing Tables
CREATE TABLE IF NOT EXISTS public.departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    department_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    helpline_phone VARCHAR(20),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.grievance_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_key VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    default_priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    default_sla_hours INTEGER NOT NULL DEFAULT 72,
    icon_name VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.department_categories (
    department_id UUID NOT NULL REFERENCES public.departments(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES public.grievance_categories(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (department_id, category_id)
);

CREATE TABLE IF NOT EXISTS public.officer_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    department_id UUID NOT NULL REFERENCES public.departments(id) ON DELETE CASCADE,
    jurisdiction_id UUID NOT NULL REFERENCES public.jurisdictions(id) ON DELETE CASCADE,
    designation VARCHAR(100) NOT NULL,
    officer_level INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. Grievances Master Record & Lifecycle
CREATE TABLE IF NOT EXISTS public.grievances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reference_number VARCHAR(50) UNIQUE NOT NULL,
    citizen_id UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
    department_id UUID NOT NULL REFERENCES public.departments(id) ON DELETE RESTRICT,
    category_id UUID NOT NULL REFERENCES public.grievance_categories(id) ON DELETE RESTRICT,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location_address TEXT NOT NULL,
    location_point GEOGRAPHY(Point, 4326) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    district_id UUID REFERENCES public.districts(id),
    jurisdiction_id UUID REFERENCES public.jurisdictions(id),
    status VARCHAR(50) NOT NULL DEFAULT 'SUBMITTED',
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    sla_deadline TIMESTAMPTZ,
    is_escalated BOOLEAN NOT NULL DEFAULT false,
    escalation_level INTEGER NOT NULL DEFAULT 0,
    assigned_officer_id UUID REFERENCES public.users(id),
    resolved_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_grievance_status CHECK (
        status IN (
            'SUBMITTED', 'UNDER_REVIEW', 'ASSIGNED', 'IN_PROGRESS',
            'FIELD_INSPECTION', 'RESOLUTION_PROPOSED', 'RESOLVED',
            'CLOSED', 'REOPENED', 'REJECTED', 'ESCALATED'
        )
    ),
    CONSTRAINT chk_grievance_priority CHECK (
        priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')
    )
);

CREATE TABLE IF NOT EXISTS public.grievance_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    grievance_id UUID NOT NULL REFERENCES public.grievances(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES public.users(id),
    storage_bucket VARCHAR(50) NOT NULL DEFAULT 'grievance-evidence',
    file_path TEXT NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_size_bytes BIGINT,
    attachment_type VARCHAR(50) NOT NULL DEFAULT 'CITIZEN_EVIDENCE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_attachment_type CHECK (
        attachment_type IN ('CITIZEN_EVIDENCE', 'FIELD_INSPECTION', 'RESOLUTION_PROOF')
    )
);

CREATE TABLE IF NOT EXISTS public.grievance_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    grievance_id UUID NOT NULL REFERENCES public.grievances(id) ON DELETE CASCADE,
    from_status VARCHAR(50),
    to_status VARCHAR(50) NOT NULL,
    changed_by UUID NOT NULL REFERENCES public.users(id),
    remarks TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.grievance_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    grievance_id UUID NOT NULL REFERENCES public.grievances(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES public.users(id),
    content TEXT NOT NULL,
    is_internal BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. Feedback & Reopen Requests
CREATE TABLE IF NOT EXISTS public.feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    grievance_id UUID UNIQUE NOT NULL REFERENCES public.grievances(id) ON DELETE CASCADE,
    citizen_id UUID NOT NULL REFERENCES public.users(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comments TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.reopen_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    grievance_id UUID NOT NULL REFERENCES public.grievances(id) ON DELETE CASCADE,
    citizen_id UUID NOT NULL REFERENCES public.users(id),
    reason TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    reviewed_by UUID REFERENCES public.users(id),
    review_remarks TEXT,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.saved_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    label VARCHAR(50) NOT NULL,
    address_line TEXT NOT NULL,
    landmark TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    district VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. SLA, Escalation & Audit Tables
CREATE TABLE IF NOT EXISTS public.sla_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    department_id UUID REFERENCES public.departments(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.grievance_categories(id) ON DELETE CASCADE,
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    target_resolution_hours INTEGER NOT NULL DEFAULT 72,
    warning_hours INTEGER NOT NULL DEFAULT 48,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.escalation_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    grievance_id UUID NOT NULL REFERENCES public.grievances(id) ON DELETE CASCADE,
    escalated_from_user UUID REFERENCES public.users(id),
    escalated_to_user UUID REFERENCES public.users(id),
    escalation_level INTEGER NOT NULL DEFAULT 1,
    reason TEXT NOT NULL,
    escalated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    actor_role VARCHAR(50),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(100) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    payload_before JSONB,
    payload_after JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    grievance_id UUID REFERENCES public.grievances(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT false,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 8. Spatial and Performance Indexes
CREATE INDEX IF NOT EXISTS idx_grievances_location_point ON public.grievances USING GIST (location_point);
CREATE INDEX IF NOT EXISTS idx_grievances_citizen_id ON public.grievances (citizen_id);
CREATE INDEX IF NOT EXISTS idx_grievances_department_id ON public.grievances (department_id);
CREATE INDEX IF NOT EXISTS idx_grievances_status ON public.grievances (status);
CREATE INDEX IF NOT EXISTS idx_grievances_assigned_officer ON public.grievances (assigned_officer_id);
CREATE INDEX IF NOT EXISTS idx_grievances_created_at ON public.grievances (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_officer_assignments_lookup ON public.officer_assignments (user_id, department_id, jurisdiction_id);
CREATE INDEX IF NOT EXISTS idx_status_history_grievance ON public.grievance_status_history (grievance_id, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON public.notifications (user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON public.audit_logs (actor_id, created_at DESC);

-- 9. Automated Reference Number Sequence & Triggers
CREATE SEQUENCE IF NOT EXISTS grievance_ref_seq START WITH 1001;

CREATE OR REPLACE FUNCTION generate_grievance_reference()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.reference_number IS NULL OR NEW.reference_number = '' THEN
        NEW.reference_number := 'GRV-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(NEXTVAL('grievance_ref_seq')::TEXT, 5, '0');
    END IF;
    IF NEW.location_point IS NULL THEN
        NEW.location_point := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
    END IF;
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_grievance_before_insert ON public.grievances;
CREATE TRIGGER trg_grievance_before_insert
BEFORE INSERT OR UPDATE ON public.grievances
FOR EACH ROW EXECUTE FUNCTION generate_grievance_reference();

-- 10. Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grievances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grievance_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grievance_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_addresses ENABLE ROW LEVEL SECURITY;

-- 11. SEED DATA EXECUTION
-- Seed Roles
INSERT INTO public.roles (name, description) VALUES
('CITIZEN', 'Citizen reporting civic complaints and tracking resolution'),
('DEPARTMENT_OFFICER', 'Department field officer managing assigned grievances in jurisdiction'),
('SENIOR_OFFICER', 'Supervisory officer monitoring department workload and approving resolutions'),
('ADMINISTRATOR', 'System administrator managing master data, assignments, and audit logs')
ON CONFLICT (name) DO NOTHING;

-- Seed State (Arunachal Pradesh)
INSERT INTO public.states (state_code, state_name) VALUES
('AR', 'Arunachal Pradesh')
ON CONFLICT (state_code) DO NOTHING;

-- Seed Districts & Wards
DO $$
DECLARE
    state_ar_id UUID;
    dist_capital_id UUID;
    dept_water UUID;
    dept_elec UUID;
    dept_roads UUID;
    dept_sanitation UUID;
    dept_edu UUID;
    dept_health UUID;
    dept_other UUID;
BEGIN
    SELECT id INTO state_ar_id FROM public.states WHERE state_code = 'AR' LIMIT 1;

    INSERT INTO public.districts (state_id, district_code, district_name, headquarters) VALUES
    (state_ar_id, 'PAPUM_PARE', 'Papum Pare', 'Yupia'),
    (state_ar_id, 'ITANAGAR_CAPITAL', 'Itanagar Capital Complex', 'Itanagar'),
    (state_ar_id, 'EAST_SIANG', 'Pasighat', 'Pasighat'),
    (state_ar_id, 'WEST_KAMENG', 'West Kameng', 'Bomdila')
    ON CONFLICT (district_code) DO NOTHING;

    SELECT id INTO dist_capital_id FROM public.districts WHERE district_code = 'ITANAGAR_CAPITAL' LIMIT 1;
    IF dist_capital_id IS NOT NULL THEN
        INSERT INTO public.administrative_areas (district_id, area_name, area_type) VALUES
        (dist_capital_id, 'Ward 01 - Ganga / Chimpu', 'WARD'),
        (dist_capital_id, 'Ward 02 - Bank Tinali / Market', 'WARD'),
        (dist_capital_id, 'Ward 03 - Chandranagar', 'WARD'),
        (dist_capital_id, 'Ward 04 - Zero Point / Raj Bhavan', 'WARD'),
        (dist_capital_id, 'Ward 05 - C-Sector / Secretariat', 'WARD'),
        (dist_capital_id, 'Ward 06 - E-Sector / Naharlagun', 'WARD')
        ON CONFLICT DO NOTHING;

        INSERT INTO public.jurisdictions (name, district_id) VALUES
        ('Itanagar Capital Urban Jurisdiction', dist_capital_id)
        ON CONFLICT DO NOTHING;
    END IF;

    -- Seed 7 Departments
    INSERT INTO public.departments (department_code, name, description, helpline_phone) VALUES
    ('WATER_SUPPLY', 'Public Health Engineering & Water Supply', 'Piped drinking water, pipeline leaks, pressure, water tankers', '1800-345-3601'),
    ('ELECTRICITY', 'Department of Power & Energy', 'Power supply, transformers, high tension wires, electric poles, streetlights', '1800-345-3602'),
    ('ROADS', 'Public Works Department (PWD Roads)', 'Road paving, potholes, broken sidewalks, road drainage, culverts', '1800-345-3603'),
    ('SANITATION', 'Urban Local Bodies & Sanitation', 'Garbage collection, waste dumping, public bins, sewage clearance', '1800-345-3604'),
    ('EDUCATION', 'Department of School Education', 'Govt school infrastructure, drinking water in schools, classroom repairs', '1800-345-3605'),
    ('HEALTHCARE', 'Health & Family Welfare Services', 'PHC infrastructure, clinic sanitation, ambulance dispatch, medical facilities', '1800-345-3606'),
    ('OTHER_SERVICES', 'General Civic Services & Administration', 'Public parks, noise pollution, stray animals, general municipal issues', '1800-345-3607')
    ON CONFLICT (department_code) DO NOTHING;

    SELECT id INTO dept_water FROM public.departments WHERE department_code = 'WATER_SUPPLY';
    SELECT id INTO dept_elec FROM public.departments WHERE department_code = 'ELECTRICITY';
    SELECT id INTO dept_roads FROM public.departments WHERE department_code = 'ROADS';
    SELECT id INTO dept_sanitation FROM public.departments WHERE department_code = 'SANITATION';

    -- Seed Categories
    INSERT INTO public.grievance_categories (category_key, name, default_priority, default_sla_hours, icon_name) VALUES
    ('water_leakage', 'Water Leakage & Pipeline Damage', 'HIGH', 48, 'water_damage'),
    ('low_water_pressure', 'Low Water Pressure / No Supply', 'HIGH', 48, 'water_drop'),
    ('contaminated_water', 'Contaminated / Muddy Water', 'CRITICAL', 24, 'warning'),
    ('power_outage', 'Frequent Power Outage / Blackout', 'HIGH', 48, 'flash_off'),
    ('damaged_pole_wire', 'Exposed Electrical Wire / Broken Pole', 'CRITICAL', 24, 'electrical_services'),
    ('streetlight_failure', 'Streetlight Not Working', 'MEDIUM', 72, 'lightbulb'),
    ('potholes', 'Potholes & Damaged Road Surface', 'MEDIUM', 72, 'construction'),
    ('broken_footpath', 'Broken Footpath & Drain Cover', 'MEDIUM', 72, 'alt_route'),
    ('road_obstruction', 'Debris / Landslide Road Blockage', 'CRITICAL', 24, 'block'),
    ('garbage_overflow', 'Overflowing Garbage Bin / Open Dump', 'MEDIUM', 48, 'delete_sweep'),
    ('drainage_blockage', 'Blocked Drain & Sewage Overflow', 'HIGH', 48, 'cleaning_services')
    ON CONFLICT (category_key) DO NOTHING;

    -- Bind Categories to Departments
    INSERT INTO public.department_categories (department_id, category_id)
    SELECT dept_water, id FROM public.grievance_categories WHERE category_key IN ('water_leakage', 'low_water_pressure', 'contaminated_water')
    ON CONFLICT DO NOTHING;

    INSERT INTO public.department_categories (department_id, category_id)
    SELECT dept_elec, id FROM public.grievance_categories WHERE category_key IN ('power_outage', 'damaged_pole_wire', 'streetlight_failure')
    ON CONFLICT DO NOTHING;

    INSERT INTO public.department_categories (department_id, category_id)
    SELECT dept_roads, id FROM public.grievance_categories WHERE category_key IN ('potholes', 'broken_footpath', 'road_obstruction')
    ON CONFLICT DO NOTHING;

    INSERT INTO public.department_categories (department_id, category_id)
    SELECT dept_sanitation, id FROM public.grievance_categories WHERE category_key IN ('garbage_overflow', 'drainage_blockage')
    ON CONFLICT DO NOTHING;
END $$;

-- Seed Default SLA Policies
INSERT INTO public.sla_policies (priority, target_resolution_hours, warning_hours) VALUES
('CRITICAL', 24, 18),
('HIGH', 48, 36),
('MEDIUM', 72, 54),
('LOW', 120, 90)
ON CONFLICT DO NOTHING;
