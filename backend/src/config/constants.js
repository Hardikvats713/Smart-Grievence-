// System-wide constants and enumerations
module.exports = {
  ROLES: {
    CITIZEN: 'CITIZEN',
    DEPARTMENT_OFFICER: 'DEPARTMENT_OFFICER',
    SENIOR_OFFICER: 'SENIOR_OFFICER',
    ADMINISTRATOR: 'ADMINISTRATOR'
  },

  GRIEVANCE_STATUS: {
    SUBMITTED: 'SUBMITTED',
    UNDER_REVIEW: 'UNDER_REVIEW',
    ASSIGNED: 'ASSIGNED',
    IN_PROGRESS: 'IN_PROGRESS',
    FIELD_INSPECTION: 'FIELD_INSPECTION',
    RESOLUTION_PROPOSED: 'RESOLUTION_PROPOSED',
    RESOLVED: 'RESOLVED',
    CLOSED: 'CLOSED',
    REOPENED: 'REOPENED',
    REJECTED: 'REJECTED',
    ESCALATED: 'ESCALATED'
  },

  PRIORITIES: {
    LOW: 'LOW',
    MEDIUM: 'MEDIUM',
    HIGH: 'HIGH',
    CRITICAL: 'CRITICAL'
  },

  SLA_HOURS: {
    CRITICAL: 24,
    HIGH: 48,
    MEDIUM: 72,
    LOW: 120
  },

  ATTACHMENT_TYPES: {
    CITIZEN_EVIDENCE: 'CITIZEN_EVIDENCE',
    FIELD_INSPECTION: 'FIELD_INSPECTION',
    RESOLUTION_PROOF: 'RESOLUTION_PROOF'
  },

  DEPARTMENTS: [
    { code: 'WATER_SUPPLY', name: 'Public Health Engineering & Water Supply' },
    { code: 'ELECTRICITY', name: 'Department of Power & Energy' },
    { code: 'ROADS', name: 'Public Works Department (PWD Roads)' },
    { code: 'SANITATION', name: 'Urban Local Bodies & Sanitation' },
    { code: 'EDUCATION', name: 'Department of School Education' },
    { code: 'HEALTHCARE', name: 'Health & Family Welfare Services' },
    { code: 'OTHER_SERVICES', name: 'General Civic Services & Administration' }
  ]
};
