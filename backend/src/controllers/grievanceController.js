// Grievance Controller - Citizen submission, tracking, feedback, reopen
const { getStore, persist, generateId } = require('../services/localStore');
const { calculateDeadline } = require('../services/slaService');
const { logAuditEvent } = require('../services/auditService');
const { createNotification } = require('../services/notificationService');
const { GRIEVANCE_STATUS, ROLES } = require('../config/constants');
const supabase = require('../config/supabase');

// GET /api/v1/grievances
async function listGrievances(req, res) {
  const store = getStore();
  const user = req.user;
  const { status, category, priority } = req.query;

  let list = [...store.grievances];

  // Citizen filter: Only see own grievances
  if (!user || user.activeRole === ROLES.CITIZEN) {
    const userId = user ? (user.sub || user.id) : null;
    const userPhone = user ? user.phone : null;
    if (userId || userPhone) {
      list = list.filter(g => g.citizen_id === userId || g.user_phone === userPhone);
    }
  }

  // Optional status, category, priority filters
  if (status) {
    list = list.filter(g => g.status.toUpperCase() === status.toUpperCase());
  }
  if (category) {
    list = list.filter(g => (g.category || '').toLowerCase() === category.toLowerCase());
  }
  if (priority) {
    list = list.filter(g => (g.priority || '').toLowerCase() === priority.toLowerCase());
  }

  // Sort descending by created_at
  list.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

  return res.success(list, 'Grievances retrieved', 200, { totalCount: list.length });
}

// GET /api/v1/grievances/:id
async function getGrievanceById(req, res) {
  const store = getStore();
  const { id } = req.params;
  const grievance = store.grievances.find(g => g.id === id || g.reference_number === id);

  if (!grievance) {
    return res.fail('Grievance not found', 404);
  }

  // Check authorization for citizens
  if (req.user && req.user.activeRole === ROLES.CITIZEN) {
    if (grievance.citizen_id !== req.user.sub && grievance.user_phone !== req.user.phone) {
      return res.fail('You are not authorized to view this grievance', 403);
    }
  }

  return res.success(grievance, 'Grievance details retrieved');
}

// POST /api/v1/grievances
async function submitGrievance(req, res) {
  const {
    categoryId,
    category,
    title,
    description,
    latitude,
    longitude,
    locationAddress,
    attachments = [],
    priority = 'MEDIUM'
  } = req.body;

  if (!title || !description || latitude === undefined || longitude === undefined || !locationAddress) {
    return res.fail('Missing required grievance fields (title, description, coordinates, address)', 400);
  }

  const store = getStore();
  const userId = req.user ? (req.user.sub || req.user.id) : generateId('usr');
  const userPhone = req.user ? req.user.phone : '+919876543210';

  // Determine Department mapping from category
  let matchedCategory = store.categories.find(c => c.id === categoryId || c.category_key === categoryId || c.name.toLowerCase() === (category || '').toLowerCase());
  const departmentId = matchedCategory ? matchedCategory.department_id : 'dept-other';
  const categoryName = matchedCategory ? matchedCategory.name : (category || 'Other Services');

  const refNumber = `GRV-2026-${String(store.grievances.length + 101).padStart(4, '0')}`;
  const grievanceId = generateId('grv');
  const deadline = calculateDeadline(priority);

  const newGrievance = {
    id: grievanceId,
    reference_number: refNumber,
    referenceNumber: refNumber, // Support camelCase for existing Flutter UI
    citizen_id: userId,
    user_phone: userPhone,
    userPhone: userPhone,
    department_id: departmentId,
    category_id: matchedCategory ? matchedCategory.id : null,
    category: categoryName,
    title,
    description,
    location_address: locationAddress,
    locationAddress: locationAddress,
    latitude: parseFloat(latitude),
    longitude: parseFloat(longitude),
    district_id: 'dist-02',
    jurisdiction_id: 'jur-itanagar-01',
    status: GRIEVANCE_STATUS.SUBMITTED,
    priority: priority.toUpperCase(),
    sla_deadline: deadline.toISOString(),
    is_escalated: false,
    escalation_level: 0,
    assigned_officer_id: null,
    attachments: attachments || [],
    timeline: [
      {
        title: 'Grievance Submitted',
        timestamp: 'Just now',
        description: 'Successfully registered with reference number ' + refNumber,
        isCompleted: true
      }
    ],
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  };

  store.grievances.unshift(newGrievance);
  persist();

  // Audit log
  await logAuditEvent({
    actorId: userId,
    actorRole: ROLES.CITIZEN,
    action: 'GRIEVANCE_SUBMITTED',
    entityType: 'grievances',
    entityId: grievanceId,
    req,
    payloadAfter: newGrievance
  });

  // Notification to citizen
  await createNotification({
    userId,
    userPhone,
    grievanceId,
    type: 'GRIEVANCE_SUBMITTED',
    title: 'Grievance Registered',
    message: `Your grievance ${refNumber} has been received and routed to ${categoryName}.`
  });

  // Attempt Supabase insert if table exists
  if (supabase) {
    try {
      await supabase.from('grievances').insert([{
        id: grievanceId,
        reference_number: refNumber,
        user_phone: userPhone,
        category: categoryName,
        title,
        description,
        location_address: locationAddress,
        latitude: parseFloat(latitude),
        longitude: parseFloat(longitude),
        status: 'Submitted',
        attachments: attachments || [],
        timeline: newGrievance.timeline
      }]);
    } catch (_) {}
  }

  return res.success(newGrievance, 'Grievance submitted successfully', 201);
}

// POST /api/v1/grievances/:id/feedback
async function submitFeedback(req, res) {
  const { id } = req.params;
  const { rating, comments } = req.body;

  if (!rating || rating < 1 || rating > 5) {
    return res.fail('Rating between 1 and 5 is required', 400);
  }

  const store = getStore();
  const grievance = store.grievances.find(g => g.id === id || g.reference_number === id);
  if (!grievance) {
    return res.fail('Grievance not found', 404);
  }

  const feedbackRecord = {
    id: generateId('fb'),
    grievance_id: grievance.id,
    rating: parseInt(rating, 10),
    comments: comments || '',
    created_at: new Date().toISOString()
  };

  grievance.feedback = feedbackRecord;
  grievance.status = GRIEVANCE_STATUS.CLOSED;
  grievance.timeline.push({
    title: 'Citizen Feedback & Closure',
    timestamp: 'Just now',
    description: `Citizen rated resolution ${rating}/5 stars. Grievance closed.`,
    isCompleted: true
  });
  grievance.updated_at = new Date().toISOString();

  persist();

  return res.success(feedbackRecord, 'Thank you for your feedback! Grievance closed.');
}

// POST /api/v1/grievances/:id/reopen
async function requestReopen(req, res) {
  const { id } = req.params;
  const { reason, attachments = [] } = req.body;

  if (!reason) {
    return res.fail('Reopening reason is required', 400);
  }

  const store = getStore();
  const grievance = store.grievances.find(g => g.id === id || g.reference_number === id);
  if (!grievance) {
    return res.fail('Grievance not found', 404);
  }

  grievance.status = GRIEVANCE_STATUS.REOPENED;
  grievance.timeline.push({
    title: 'Reopened by Citizen',
    timestamp: 'Just now',
    description: `Citizen requested reopening: "${reason}"`,
    isCompleted: true
  });
  grievance.updated_at = new Date().toISOString();

  persist();

  await createNotification({
    userId: grievance.citizen_id,
    userPhone: grievance.user_phone,
    grievanceId: grievance.id,
    type: 'GRIEVANCE_REOPENED',
    title: 'Grievance Reopened',
    message: `Grievance ${grievance.reference_number} has been reopened for supervisory review.`
  });

  return res.success(grievance, 'Grievance reopened successfully');
}

module.exports = {
  listGrievances,
  getGrievanceById,
  submitGrievance,
  submitFeedback,
  requestReopen
};
