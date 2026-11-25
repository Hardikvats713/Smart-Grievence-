// Department & Senior Officer Controller - Jurisdiction & Lifecycle Workflow
const { getStore, persist, generateId } = require('../services/localStore');
const { GRIEVANCE_STATUS, ROLES } = require('../config/constants');
const { evaluateSlaStatus } = require('../services/slaService');
const { logAuditEvent } = require('../services/auditService');
const { createNotification } = require('../services/notificationService');

// Allowed status transitions for officers
const ALLOWED_TRANSITIONS = {
  [GRIEVANCE_STATUS.SUBMITTED]: [GRIEVANCE_STATUS.UNDER_REVIEW, GRIEVANCE_STATUS.ASSIGNED, GRIEVANCE_STATUS.IN_PROGRESS, GRIEVANCE_STATUS.REJECTED],
  [GRIEVANCE_STATUS.UNDER_REVIEW]: [GRIEVANCE_STATUS.ASSIGNED, GRIEVANCE_STATUS.IN_PROGRESS, GRIEVANCE_STATUS.REJECTED],
  [GRIEVANCE_STATUS.ASSIGNED]: [GRIEVANCE_STATUS.IN_PROGRESS, GRIEVANCE_STATUS.FIELD_INSPECTION, GRIEVANCE_STATUS.REJECTED],
  [GRIEVANCE_STATUS.IN_PROGRESS]: [GRIEVANCE_STATUS.FIELD_INSPECTION, GRIEVANCE_STATUS.RESOLUTION_PROPOSED, GRIEVANCE_STATUS.RESOLVED],
  [GRIEVANCE_STATUS.FIELD_INSPECTION]: [GRIEVANCE_STATUS.IN_PROGRESS, GRIEVANCE_STATUS.RESOLUTION_PROPOSED],
  [GRIEVANCE_STATUS.RESOLUTION_PROPOSED]: [GRIEVANCE_STATUS.RESOLVED, GRIEVANCE_STATUS.IN_PROGRESS],
  [GRIEVANCE_STATUS.REOPENED]: [GRIEVANCE_STATUS.IN_PROGRESS, GRIEVANCE_STATUS.FIELD_INSPECTION],
  [GRIEVANCE_STATUS.RESOLVED]: [GRIEVANCE_STATUS.CLOSED],
  [GRIEVANCE_STATUS.CLOSED]: [],
  [GRIEVANCE_STATUS.REJECTED]: []
};

// GET /api/v1/officer/grievances
async function getOfficerQueue(req, res) {
  const store = getStore();
  const user = req.user;

  let queue = [...store.grievances];

  // Jurisdiction & Department filtering
  if (user && user.activeRole === ROLES.DEPARTMENT_OFFICER) {
    if (user.departmentId) {
      queue = queue.filter(g => g.department_id === user.departmentId);
    }
  }

  // Enrich each grievance with real-time SLA calculation
  const enriched = queue.map(g => {
    const sla = evaluateSlaStatus(g.created_at, g.sla_deadline);
    return {
      ...g,
      slaStatus: sla.status,
      elapsedPercent: sla.elapsedPercent,
      overdueHours: sla.overdueHours || 0,
      hoursRemaining: sla.hoursRemaining || 0
    };
  });

  return res.success(enriched, 'Officer queue retrieved', 200, {
    totalQueue: enriched.length,
    departmentId: user ? user.departmentId : null
  });
}

// PATCH /api/v1/officer/grievances/:id/status
async function updateGrievanceStatus(req, res) {
  const { id } = req.params;
  const { status, remarks = '', resolutionProof = [] } = req.body;

  if (!status) {
    return res.fail('Target status is required', 400);
  }

  const store = getStore();
  const grievance = store.grievances.find(g => g.id === id || g.reference_number === id);

  if (!grievance) {
    return res.fail('Grievance not found', 404);
  }

  const currentStatus = (grievance.status || 'SUBMITTED').toUpperCase();
  const targetStatus = status.toUpperCase();

  // Validate status transition
  const validTargets = ALLOWED_TRANSITIONS[currentStatus] || [];
  if (!validTargets.includes(targetStatus) && req.user.activeRole !== ROLES.ADMINISTRATOR) {
    return res.fail(`Illegal state transition from ${currentStatus} to ${targetStatus}`, 422, {
      currentStatus,
      allowedNextStates: validTargets
    });
  }

  // Update status & timeline
  const previousStatus = grievance.status;
  grievance.status = targetStatus;
  grievance.updated_at = new Date().toISOString();

  if (targetStatus === GRIEVANCE_STATUS.RESOLVED) {
    grievance.resolved_at = new Date().toISOString();
  }

  if (resolutionProof && resolutionProof.length > 0) {
    grievance.resolutionProof = resolutionProof;
  }

  // Append milestone to timeline
  grievance.timeline.push({
    title: targetStatus.replace(/_/g, ' '),
    timestamp: 'Just now',
    description: remarks || `Status updated to ${targetStatus} by ${req.user.phone || 'officer'}`,
    isCompleted: true
  });

  // Append to status history
  const historyEntry = {
    id: generateId('hist'),
    grievance_id: grievance.id,
    from_status: previousStatus,
    to_status: targetStatus,
    changed_by: req.user.sub,
    remarks: remarks || '',
    created_at: new Date().toISOString()
  };
  store.status_history.push(historyEntry);

  persist();

  // Security audit log
  await logAuditEvent({
    actorId: req.user.sub,
    actorRole: req.user.activeRole,
    action: 'OFFICER_STATUS_UPDATE',
    entityType: 'grievances',
    entityId: grievance.id,
    req,
    payloadBefore: { status: previousStatus },
    payloadAfter: { status: targetStatus, remarks }
  });

  // Notify citizen
  await createNotification({
    userId: grievance.citizen_id,
    userPhone: grievance.user_phone,
    grievanceId: grievance.id,
    type: 'GRIEVANCE_STATUS_UPDATE',
    title: `Grievance ${targetStatus.replace(/_/g, ' ')}`,
    message: remarks || `Your grievance ${grievance.reference_number} has been updated to ${targetStatus.replace(/_/g, ' ')}.`
  });

  return res.success(grievance, `Status updated to ${targetStatus}`);
}

// POST /api/v1/officer/grievances/:id/remarks
async function addInvestigationRemark(req, res) {
  const { id } = req.params;
  const { remark, isInternal = true } = req.body;

  if (!remark) {
    return res.fail('Remark text is required', 400);
  }

  const store = getStore();
  const grievance = store.grievances.find(g => g.id === id || g.reference_number === id);

  if (!grievance) {
    return res.fail('Grievance not found', 404);
  }

  const commentRecord = {
    id: generateId('comment'),
    grievance_id: grievance.id,
    author_id: req.user.sub,
    author_phone: req.user.phone,
    author_role: req.user.activeRole,
    content: remark,
    is_internal: isInternal,
    created_at: new Date().toISOString()
  };

  store.comments.push(commentRecord);
  persist();

  return res.success(commentRecord, 'Investigation remark added successfully', 201);
}

module.exports = {
  getOfficerQueue,
  updateGrievanceStatus,
  addInvestigationRemark
};
