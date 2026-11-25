-- ============================================================================
-- SMART GRIEVANCE (ARUNACHAL PRADESH) - INITIAL SEED DATA
-- Migration: 20261125000002_seed_initial_data.sql
-- ============================================================================

-- 1. Seed Roles
INSERT INTO public.roles (name, description) VALUES
('CITIZEN', 'Citizen reporting civic complaints and tracking resolution'),
('DEPARTMENT_OFFICER', 'Department field officer managing assigned grievances in jurisdiction'),
('SENIOR_OFFICER', 'Supervisory officer monitoring department workload and approving resolutions'),
('ADMINISTRATOR', 'System administrator managing master data, assignments, and audit logs')
ON CONFLICT (name) DO NOTHING;

-- 2. Seed State (Arunachal Pradesh)
INSERT INTO public.states (state_code, state_name) VALUES
('AR', 'Arunachal Pradesh')
ON CONFLICT (state_code) DO NOTHING;

-- 3. Seed Districts
DO $$
DECLARE
    state_ar_id UUID;
BEGIN
    SELECT id INTO state_ar_id FROM public.states WHERE state_code = 'AR' LIMIT 1;

    INSERT INTO public.districts (state_id, district_code, district_name, headquarters) VALUES
    (state_ar_id, 'PAPUM_PARE', 'Papum Pare', 'Yupia'),
    (state_ar_id, 'ITANAGAR_CAPITAL', 'Itanagar Capital Complex', 'Itanagar'),
    (state_ar_id, 'EAST_SIANG', 'East Siang', 'Pasighat'),
    (state_ar_id, 'WEST_KAMENG', 'West Kameng', 'Bomdila'),
    (state_ar_id, 'TAWANG', 'Tawang', 'Tawang'),
    (state_ar_id, 'LOWER_SUBANSIRI', 'Lower Subansiri', 'Ziro'),
    (state_ar_id, 'CHANGLANG', 'Changlang', 'Changlang')
    ON CONFLICT (district_code) DO NOTHING;
END $$;

-- 4. Seed Administrative Areas (Wards under Capital Complex)
DO $$
DECLARE
    dist_capital_id UUID;
BEGIN
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

        -- Seed Default Capital Jurisdictions
        INSERT INTO public.jurisdictions (name, district_id) VALUES
        ('Itanagar Capital Urban Jurisdiction', dist_capital_id)
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- 5. Seed Core 7 Departments
INSERT INTO public.departments (department_code, name, description, helpline_phone) VALUES
('WATER_SUPPLY', 'Public Health Engineering & Water Supply', 'Piped drinking water, pipeline leaks, pressure, water tankers', '1800-345-3601'),
('ELECTRICITY', 'Department of Power & Energy', 'Power supply, transformers, high tension wires, electric poles, streetlights', '1800-345-3602'),
('ROADS', 'Public Works Department (PWD Roads)', 'Road paving, potholes, broken sidewalks, road drainage, culverts', '1800-345-3603'),
('SANITATION', 'Urban Local Bodies & Sanitation', 'Garbage collection, waste dumping, public bins, sewage clearance', '1800-345-3604'),
('EDUCATION', 'Department of School Education', 'Govt school infrastructure, drinking water in schools, classroom repairs', '1800-345-3605'),
('HEALTHCARE', 'Health & Family Welfare Services', 'PHC infrastructure, clinic sanitation, ambulance dispatch, medical facilities', '1800-345-3606'),
('OTHER_SERVICES', 'General Civic Services & Administration', 'Public parks, noise pollution, stray animals, general municipal issues', '1800-345-3607')
ON CONFLICT (department_code) DO NOTHING;

-- 6. Seed Grievance Categories & Map to Departments
DO $$
DECLARE
    dept_water UUID;
    dept_elec UUID;
    dept_roads UUID;
    dept_sanitation UUID;
    dept_edu UUID;
    dept_health UUID;
    dept_other UUID;
BEGIN
    SELECT id INTO dept_water FROM public.departments WHERE department_code = 'WATER_SUPPLY';
    SELECT id INTO dept_elec FROM public.departments WHERE department_code = 'ELECTRICITY';
    SELECT id INTO dept_roads FROM public.departments WHERE department_code = 'ROADS';
    SELECT id INTO dept_sanitation FROM public.departments WHERE department_code = 'SANITATION';
    SELECT id INTO dept_edu FROM public.departments WHERE department_code = 'EDUCATION';
    SELECT id INTO dept_health FROM public.departments WHERE department_code = 'HEALTHCARE';
    SELECT id INTO dept_other FROM public.departments WHERE department_code = 'OTHER_SERVICES';

    -- Water Supply Categories
    INSERT INTO public.grievance_categories (category_key, name, default_priority, default_sla_hours, icon_name)
    VALUES
    ('water_leakage', 'Water Leakage & Pipeline Damage', 'HIGH', 48, 'water_damage'),
    ('low_water_pressure', 'Low Water Pressure / No Supply', 'HIGH', 48, 'water_drop'),
    ('contaminated_water', 'Contaminated / Muddy Water', 'CRITICAL', 24, 'warning')
    ON CONFLICT (category_key) DO NOTHING;

    -- Electricity Categories
    INSERT INTO public.grievance_categories (category_key, name, default_priority, default_sla_hours, icon_name)
    VALUES
    ('power_outage', 'Frequent Power Outage / Blackout', 'HIGH', 48, 'flash_off'),
    ('damaged_pole_wire', 'Exposed Electrical Wire / Broken Pole', 'CRITICAL', 24, 'electrical_services'),
    ('streetlight_failure', 'Streetlight Not Working', 'MEDIUM', 72, 'lightbulb')
    ON CONFLICT (category_key) DO NOTHING;

    -- Roads Categories
    INSERT INTO public.grievance_categories (category_key, name, default_priority, default_sla_hours, icon_name)
    VALUES
    ('potholes', 'Potholes & Damaged Road Surface', 'MEDIUM', 72, 'construction'),
    ('broken_footpath', 'Broken Footpath & Drain Cover', 'MEDIUM', 72, 'alt_route'),
    ('road_obstruction', 'Debris / Landslide Road Blockage', 'CRITICAL', 24, 'block')
    ON CONFLICT (category_key) DO NOTHING;

    -- Sanitation Categories
    INSERT INTO public.grievance_categories (category_key, name, default_priority, default_sla_hours, icon_name)
    VALUES
    ('garbage_overflow', 'Overflowing Garbage Bin / Open Dump', 'MEDIUM', 48, 'delete_sweep'),
    ('drainage_blockage', 'Blocked Drain & Sewage Overflow', 'HIGH', 48, 'cleaning_services')
    ON CONFLICT (category_key) DO NOTHING;

    -- Map Categories to Responsible Departments
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

-- 7. Seed Default SLA Policies
INSERT INTO public.sla_policies (priority, target_resolution_hours, warning_hours) VALUES
('CRITICAL', 24, 18),
('HIGH', 48, 36),
('MEDIUM', 72, 54),
('LOW', 120, 90)
ON CONFLICT DO NOTHING;
