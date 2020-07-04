const {PubSub} = require('@google-cloud/pubsub');
require('dotenv').config()

class PubsubClient {
    constructor() {
        this.projectId = process.env.PROJECT_ID;
        this.topicName = process.env.TOPIC_NAME;
        this.pubsub = new PubSub(this.projectId);
    }

    async publishMessage(data) {
        if (!data) {
            throw new Error('No data found');
        }

        const dataBuffer = Buffer.from(data);
        return await this.pubsub.topic(this.topicName).publish(dataBuffer);
    }

}

module.exports = new PubsubClient();
