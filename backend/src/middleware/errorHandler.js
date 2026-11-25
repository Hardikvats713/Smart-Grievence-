// Global error handling middleware
module.exports = function errorHandler(err, req, res, next) {
  console.error(`[API ERROR] ${req.method} ${req.originalUrl}:`, err);

  const statusCode = err.status || err.statusCode || 500;
  const message = err.isPublic ? err.message : (statusCode === 500 ? 'Internal server error' : err.message);

  return res.status(statusCode).json({
    success: false,
    message: message || 'An unexpected error occurred',
    error: process.env.NODE_ENV === 'development' ? {
      name: err.name,
      message: err.message,
      stack: err.stack
    } : undefined,
    meta: {
      timestamp: new Date().toISOString(),
      path: req.originalUrl
    }
  });
};
