const app = require('./app/app');
require('dotenv').config();
const PORT = process.env.PUBLISHER_SERVICE_PORT || 8080;

app.listen(PORT, () => {
   console.log(`Publisher service listening on port ${PORT}`)
});

