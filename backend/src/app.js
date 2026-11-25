const express = require('express');
const cors = require('cors');
const responseEnvelope = require('./middleware/envelope');
const errorHandler = require('./middleware/errorHandler');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const departmentRoutes = require('./routes/departmentRoutes');
const geographyRoutes = require('./routes/geographyRoutes');
const grievanceRoutes = require('./routes/grievanceRoutes');
const officerRoutes = require('./routes/officerRoutes');
const analyticsRoutes = require('./routes/analyticsRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const supabase = require('./config/supabase');

const app = express();

// Global Middlewares
app.use(cors());
app.use(express.json({ limit: '15mb' }));
app.use(responseEnvelope);

// Health Check Endpoint (/api/v1/health and /api/health)
const healthHandler = (req, res) => {
  return res.success({
    status: 'healthy',
    service: 'smart-grievance-backend',
    version: '1.0.0',
    storage: supabase ? 'supabase' : 'local',
    timestamp: new Date().toISOString()
  }, 'Smart Grievance API v1 is operational');
};

app.get('/api/v1/health', healthHandler);
app.get('/api/health', healthHandler);

// Versioned REST API (/api/v1/)
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/departments', departmentRoutes);
app.use('/api/v1/geography', geographyRoutes);
app.use('/api/v1/grievances', grievanceRoutes);
app.use('/api/v1/officer', officerRoutes);
app.use('/api/v1/analytics', analyticsRoutes);
app.use('/api/v1/notifications', notificationRoutes);

// Legacy /api/* compatibility routes for existing mobile clients
app.use('/api/auth', authRoutes);
app.use('/api/grievances', grievanceRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/profile', userRoutes);

// 404 Handler
app.use((req, res) => {
  return res.fail(`Endpoint ${req.method} ${req.originalUrl} not found`, 404);
});

// Error Handler
app.use(errorHandler);

module.exports = app;
