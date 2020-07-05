const {PubSub} = require('@google-cloud/pubsub');
const datastoreClient = require('./datastoreClient');
require('dotenv').config()

class PubsubClient {
    constructor() {
        this.projectId = process.env.PROJECT_ID;
        this.pubsub = new PubSub(this.projectId);
        this.subscriberName = process.env.SUBSCRIBER_NAME;
        this.timeout = process.env.SUBSCRIPTION_TIMEOUT;
    }

    listenForPullMessage() {
        const subscription = this.pubsub.subscription(this.subscriberName);
        let messageCount = 0;

        const messageHandler = async message => {
            console.log(`Received message ${message.id}:`);
            messageCount += 1;
            const doc = await datastoreClient.addTicket(JSON.parse(message.data));
            if (doc instanceof Error) {
                console.error(`Unable to process message, error ${doc.message}`);
            } else {
                console.log(`Ticket document ${doc.id} created successfully`);
                message.ack();
            }
        }


        const errorHandler = function (error) {
            // Do something with the error
            console.error(`ERROR: ${error.toString()}`);
            throw error;
        };

        subscription.on('message', messageHandler);
        subscription.on('error', errorHandler);


        setTimeout(() => {
            subscription.removeListener('message', messageHandler);
            subscription.removeListener('error', errorHandler);
            console.log(`${messageCount} message(s) received.`);
        }, this.timeout * 1000);

    }
}

module.exports = new PubsubClient();
