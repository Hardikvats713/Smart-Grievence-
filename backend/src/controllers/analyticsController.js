// Analytics and Executive Performance Dashboard Controller
const { getStore } = require('../services/localStore');
const { evaluateSlaStatus } = require('../services/slaService');

// GET /api/v1/analytics/overview
async function getOverview(req, res) {
  const store = getStore();
  const grievances = store.grievances;

  const totalCount = grievances.length;
  let resolvedCount = 0;
  let inProgressCount = 0;
  let submittedCount = 0;
  let breachedCount = 0;
  let warningCount = 0;

  const departmentCounts = {};
  const categoryCounts = {};

  grievances.forEach(g => {
    // Status breakdown
    const st = (g.status || '').toUpperCase();
    if (st === 'RESOLVED' || st === 'CLOSED') {
      resolvedCount++;
    } else if (st === 'IN_PROGRESS' || st === 'FIELD_INSPECTION' || st === 'RESOLUTION_PROPOSED') {
      inProgressCount++;
    } else {
      submittedCount++;
    }

    // SLA breakdown
    const sla = evaluateSlaStatus(g.created_at, g.sla_deadline);
    if (sla.status === 'BREACHED') breachedCount++;
    if (sla.status === 'WARNING') warningCount++;

    // Dept breakdown
    const dept = g.department_id || 'OTHER';
    departmentCounts[dept] = (departmentCounts[dept] || 0) + 1;

    // Category breakdown
    const cat = g.category || 'Other';
    categoryCounts[cat] = (categoryCounts[cat] || 0) + 1;
  });

  const resolutionRate = totalCount > 0 ? Math.round((resolvedCount / totalCount) * 100) : 0;

  return res.success({
    summary: {
      totalGrievances: totalCount,
      resolved: resolvedCount,
      inProgress: inProgressCount,
      submitted: submittedCount,
      breached: breachedCount,
      approachingBreach: warningCount,
      resolutionRatePercent: resolutionRate
    },
    byDepartment: departmentCounts,
    byCategory: categoryCounts,
    timestamp: new Date().toISOString()
  }, 'Civic analytics overview generated');
}

module.exports = {
  getOverview
};
