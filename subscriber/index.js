const app = require('./app/app');
require('dotenv').config();

const PORT = process.env.SUBSCRIBER_SERVICE_PORT || 8080;

app.listen(PORT, () => {
    console.log(`Subscriber service listening on port ${PORT}`)
});

