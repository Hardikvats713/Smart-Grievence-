// SLA and Escalation Engine Service
const { SLA_HOURS, PRIORITIES } = require('../config/constants');

function calculateDeadline(priority = PRIORITIES.MEDIUM, hoursOverride = null) {
  const hours = hoursOverride || SLA_HOURS[priority] || SLA_HOURS.MEDIUM;
  return new Date(Date.now() + hours * 3600 * 1000);
}

function evaluateSlaStatus(createdAt, deadline) {
  if (!deadline) return { status: 'NORMAL', elapsedPercent: 0 };

  const start = new Date(createdAt).getTime();
  const end = new Date(deadline).getTime();
  const now = Date.now();

  const totalDuration = end - start;
  const elapsed = now - start;
  const elapsedPercent = Math.min(Math.round((elapsed / totalDuration) * 100), 200);

  if (now > end) {
    return {
      status: 'BREACHED',
      elapsedPercent,
      overdueHours: Math.round((now - end) / (3600 * 1000)),
      escalationLevel: elapsedPercent >= 150 ? 3 : 2
    };
  } else if (elapsedPercent >= 75) {
    return {
      status: 'WARNING',
      elapsedPercent,
      hoursRemaining: Math.round((end - now) / (3600 * 1000)),
      escalationLevel: 1
    };
  }

  return {
    status: 'NORMAL',
    elapsedPercent,
    hoursRemaining: Math.round((end - now) / (3600 * 1000)),
    escalationLevel: 0
  };
}

module.exports = {
  calculateDeadline,
  evaluateSlaStatus
};
