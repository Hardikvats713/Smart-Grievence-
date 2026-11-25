// High-fidelity local persistence engine
// Serves as an immediate zero-downtime cache & fallback when remote Supabase tables
// are awaiting migration execution in Supabase SQL editor.
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const DATA_DIR = path.join(__dirname, '..', '..', 'data');
const STORE_PATH = path.join(DATA_DIR, 'smart_grievance_store.json');

function initStore() {
  if (!fs.existsSync(DATA_DIR)) {
    fs.mkdirSync(DATA_DIR, { recursive: true });
  }

  if (fs.existsSync(STORE_PATH)) {
    try {
      return JSON.parse(fs.readFileSync(STORE_PATH, 'utf8'));
    } catch (_) {
      // Re-initialize if corrupted
    }
  }

  const initialStore = {
    users: [
      {
        id: 'usr-cit-001',
        phone_number: '+919876543210',
        full_name: 'Taba Tadar',
        email: 'taba.tadar@arunachal.gov.in',
        district: 'Papum Pare',
        primary_role: 'CITIZEN',
        roles: ['CITIZEN'],
        photo_url: null,
        created_at: new Date().toISOString()
      },
      {
        id: 'usr-off-001',
        phone_number: '+919436000001',
        full_name: 'Kaling Moyong (JE Roads)',
        email: 'kaling.pwd@arunachal.gov.in',
        district: 'Itanagar Capital Complex',
        primary_role: 'DEPARTMENT_OFFICER',
        roles: ['DEPARTMENT_OFFICER'],
        department_id: 'dept-roads',
        jurisdiction_id: 'jur-itanagar-01',
        created_at: new Date().toISOString()
      },
      {
        id: 'usr-off-002',
        phone_number: '+919436000002',
        full_name: 'Nabam Rebia (JE Water)',
        email: 'nabam.phe@arunachal.gov.in',
        district: 'Itanagar Capital Complex',
        primary_role: 'DEPARTMENT_OFFICER',
        roles: ['DEPARTMENT_OFFICER'],
        department_id: 'dept-water',
        jurisdiction_id: 'jur-itanagar-01',
        created_at: new Date().toISOString()
      },
      {
        id: 'usr-snr-001',
        phone_number: '+919436000003',
        full_name: 'Tage Hinda (SDO Capital)',
        email: 'tage.sdo@arunachal.gov.in',
        district: 'Itanagar Capital Complex',
        primary_role: 'SENIOR_OFFICER',
        roles: ['SENIOR_OFFICER'],
        department_id: null,
        jurisdiction_id: 'jur-itanagar-01',
        created_at: new Date().toISOString()
      },
      {
        id: 'usr-adm-001',
        phone_number: '+919436000004',
        full_name: 'District Administrator',
        email: 'admin.dc@arunachal.gov.in',
        district: 'Papum Pare',
        primary_role: 'ADMINISTRATOR',
        roles: ['ADMINISTRATOR'],
        created_at: new Date().toISOString()
      }
    ],
    departments: [
      { id: 'dept-water', code: 'WATER_SUPPLY', name: 'Public Health Engineering & Water Supply', helpline: '1800-345-3601' },
      { id: 'dept-elec', code: 'ELECTRICITY', name: 'Department of Power & Energy', helpline: '1800-345-3602' },
      { id: 'dept-roads', code: 'ROADS', name: 'Public Works Department (PWD Roads)', helpline: '1800-345-3603' },
      { id: 'dept-sanitation', code: 'SANITATION', name: 'Urban Local Bodies & Sanitation', helpline: '1800-345-3604' },
      { id: 'dept-edu', code: 'EDUCATION', name: 'Department of School Education', helpline: '1800-345-3605' },
      { id: 'dept-health', code: 'HEALTHCARE', name: 'Health & Family Welfare Services', helpline: '1800-345-3606' },
      { id: 'dept-other', code: 'OTHER_SERVICES', name: 'General Civic Services & Administration', helpline: '1800-345-3607' }
    ],
    categories: [
      { id: 'cat-roads-1', department_id: 'dept-roads', category_key: 'potholes', name: 'Potholes & Damaged Road Surface', default_priority: 'MEDIUM', default_sla_hours: 72 },
      { id: 'cat-roads-2', department_id: 'dept-roads', category_key: 'broken_footpath', name: 'Broken Footpath & Drain Cover', default_priority: 'MEDIUM', default_sla_hours: 72 },
      { id: 'cat-water-1', department_id: 'dept-water', category_key: 'water_leakage', name: 'Water Leakage & Pipeline Damage', default_priority: 'HIGH', default_sla_hours: 48 },
      { id: 'cat-water-2', department_id: 'dept-water', category_key: 'low_water_pressure', name: 'Low Water Pressure / No Supply', default_priority: 'HIGH', default_sla_hours: 48 },
      { id: 'cat-elec-1', department_id: 'dept-elec', category_key: 'power_outage', name: 'Frequent Power Outage / Blackout', default_priority: 'HIGH', default_sla_hours: 48 },
      { id: 'cat-elec-2', department_id: 'dept-elec', category_key: 'damaged_pole_wire', name: 'Exposed Electrical Wire / Broken Pole', default_priority: 'CRITICAL', default_sla_hours: 24 },
      { id: 'cat-san-1', department_id: 'dept-sanitation', category_key: 'garbage_overflow', name: 'Overflowing Garbage Bin / Open Dump', default_priority: 'MEDIUM', default_sla_hours: 48 }
    ],
    districts: [
      { id: 'dist-01', code: 'PAPUM_PARE', name: 'Papum Pare', hq: 'Yupia' },
      { id: 'dist-02', code: 'ITANAGAR_CAPITAL', name: 'Itanagar Capital Complex', hq: 'Itanagar' },
      { id: 'dist-03', code: 'EAST_SIANG', name: 'East Siang', hq: 'Pasighat' },
      { id: 'dist-04', code: 'WEST_KAMENG', name: 'West Kameng', hq: 'Bomdila' }
    ],
    wards: [
      { id: 'w-01', district_id: 'dist-02', name: 'Ward 01 - Ganga / Chimpu' },
      { id: 'w-02', district_id: 'dist-02', name: 'Ward 02 - Bank Tinali / Market' },
      { id: 'w-03', district_id: 'dist-02', name: 'Ward 03 - Chandranagar' },
      { id: 'w-04', district_id: 'dist-02', name: 'Ward 04 - Zero Point' },
      { id: 'w-05', district_id: 'dist-02', name: 'Ward 05 - C-Sector' }
    ],
    grievances: [
      {
        id: 'grv-101',
        reference_number: 'GRV-2026-0101',
        citizen_id: 'usr-cit-001',
        user_phone: '+919876543210',
        department_id: 'dept-roads',
        category_id: 'cat-roads-1',
        category: 'Roads',
        title: 'Deep pothole near Bank Tinali Junction',
        description: 'Large dangerous pothole causing severe traffic congestion and bike accidents near Bank Tinali.',
        location_address: 'Bank Tinali, VIP Road, Itanagar, Arunachal Pradesh',
        latitude: 27.0984,
        longitude: 93.6288,
        district_id: 'dist-02',
        jurisdiction_id: 'jur-itanagar-01',
        status: 'IN_PROGRESS',
        priority: 'MEDIUM',
        assigned_officer_id: 'usr-off-001',
        sla_deadline: new Date(Date.now() + 86400000 * 2).toISOString(),
        is_escalated: false,
        escalation_level: 0,
        attachments: [],
        timeline: [
          { title: 'Grievance Submitted', timestamp: '2 days ago', description: 'Registered by citizen with GPS location', isCompleted: true },
          { title: 'Assigned to PWD Roads', timestamp: '1 day ago', description: 'Assigned to JE Kaling Moyong (Ward 02)', isCompleted: true },
          { title: 'Field Inspection Dispatched', timestamp: 'Today', description: 'Site survey team mobilized for asphalt leveling', isCompleted: true }
        ],
        created_at: new Date(Date.now() - 86400000 * 2).toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: 'grv-102',
        reference_number: 'GRV-2026-0102',
        citizen_id: 'usr-cit-001',
        user_phone: '+919876543210',
        department_id: 'dept-water',
        category_id: 'cat-water-1',
        category: 'Water Supply',
        title: 'Broken main water supply pipeline',
        description: 'Piped drinking water leaking heavily onto the main road in Sector 12 since morning.',
        location_address: 'Market Complex, Sector 12, Itanagar, Arunachal Pradesh',
        latitude: 27.1010,
        longitude: 93.6190,
        district_id: 'dist-02',
        jurisdiction_id: 'jur-itanagar-01',
        status: 'SUBMITTED',
        priority: 'HIGH',
        assigned_officer_id: 'usr-off-002',
        sla_deadline: new Date(Date.now() + 86400000).toISOString(),
        is_escalated: false,
        escalation_level: 0,
        attachments: [],
        timeline: [
          { title: 'Grievance Submitted', timestamp: '1 day ago', description: 'Registered by citizen', isCompleted: true }
        ],
        created_at: new Date(Date.now() - 86400000).toISOString(),
        updated_at: new Date().toISOString()
      }
    ],
    status_history: [],
    comments: [],
    feedback: [],
    notifications: [
      {
        id: 'notif-1',
        user_id: 'usr-cit-001',
        user_phone: '+919876543210',
        type: 'STATUS_UPDATE',
        title: 'Grievance In Progress',
        message: 'Your complaint GRV-2026-0101 has been moved to In Progress by PWD Roads.',
        grievance_id: 'grv-101',
        is_read: false,
        created_at: new Date(Date.now() - 3600000).toISOString()
      }
    ],
    audit_logs: []
  };

  fs.writeFileSync(STORE_PATH, JSON.stringify(initialStore, null, 2));
  return initialStore;
}

let store = initStore();

function persist() {
  fs.writeFileSync(STORE_PATH, JSON.stringify(store, null, 2));
}

module.exports = {
  getStore: () => store,
  persist,
  generateId: (prefix = 'id') => `${prefix}-${crypto.randomBytes(4).toString('hex')}`
};
