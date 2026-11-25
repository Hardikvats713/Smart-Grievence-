const app = require('./app');
const config = require('./config/env');

if (require.main === module) {
  app.listen(config.PORT, () => {
    console.log(`Smart Grievance API v1 running on http://localhost:${config.PORT}`);
    console.log(`Health endpoint: http://localhost:${config.PORT}/api/v1/health`);
  });
}

module.exports = app;
