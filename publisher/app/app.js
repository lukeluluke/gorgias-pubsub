const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const Response = require('../lib/response');
const PubSubClient = require('../lib/pubsubClient');
require('dotenv').config()

const app = express();
app.use(bodyParser.json());


const verifyToken = () => {
    return (req, res, next) => {
        if (!req.header('Authorization')) {
            return Response.jsonFailed(res, 400, 'Unauthorized Request');
        }

        const bearer = req.header('Authorization');
        const [, token] = bearer.match(/Bearer (.*)/);
        if (token !== process.env.VERIFICATION_TOKEN) {
            return Response.jsonFailed(res, 400, 'Invalid token');
        }
        next();
    }
}



app.post('/publish-ticket', verifyToken(), async (req, res) => {

    if (!req.body) {
        const msg = 'Invalid ticket';
        return Response.jsonFailed(res, 400, msg);
    }
    const ticket = req.body;
    try {
        const messageId = await PubSubClient.publishMessage(JSON.stringify(ticket));
        console.log(`Message[${messageId}] is created `);
        return Response.jsonSuccess(res, {messageId: messageId}, 'success');
    } catch (e) {
        return Response.jsonFailed(res, 400, e.toString(), ticket);
    }

})


app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname + '/../index.html'))
})

module.exports = app;
