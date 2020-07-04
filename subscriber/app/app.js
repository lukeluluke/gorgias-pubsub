const express = require('express');
const Response = require('../lib/response');
const PubSubClient = require('../lib/pubsubClient');
require('dotenv').config()

const app = express();
app.post('/pull', async (req, res) => {
    try {
        PubSubClient.listenForPullMessage();
        return Response.jsonSuccess(res, 204, 'success');
    } catch (e) {
        return Response.jsonFailed(res, 400, e.toString());
    }

})

module.exports = app;
