// Standard API response envelope formatter
// Output: { success: boolean, message: string, data?: any, meta?: object, error?: object }

module.exports = function responseEnvelope(req, res, next) {
  res.success = function(data = null, message = 'Success', statusCode = 200, meta = {}) {
    return res.status(statusCode).json({
      success: true,
      message,
      data,
      meta: {
        timestamp: new Date().toISOString(),
        path: req.originalUrl,
        ...meta
      }
    });
  };

  res.fail = function(message = 'An error occurred', statusCode = 400, errors = null) {
    return res.status(statusCode).json({
      success: false,
      message,
      error: errors,
      meta: {
        timestamp: new Date().toISOString(),
        path: req.originalUrl
      }
    });
  };

  next();
};
