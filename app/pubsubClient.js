const {PubSub} = require('@google-cloud/pubsub');
require('dotenv').config()

class PubsubClient {
    constructor() {
        this.projectId = process.env.PROJECT_ID;
        this.topicName = process.env.TOPIC_NAME;
        this.pubsub = new PubSub(this.projectId);
        this.subscriberName = process.env.SUBSCRIBER_NAME;
    }

    async initializePubSub() {
        try {
            console.log('initialize pubsub ...')
            await this.createTopic();
            await this.createSubscriber();
            console.log('Success!!!');
        } catch (e) {
            console.error(`Unable to create pubsub, error ${e.toString()}`);
        }


    }

    async createTopic() {
        await this.pubsub.createTopic(this.topicName);
        console.log(`Topic ${this.topicName} created`);
    }

    async createSubscriber() {
        await this.pubsub.topic(this.topicName).createSubscription(this.subscriberName);
        console.log(`Subscriber ${this.subscriberName} created`);
    }

}

module.exports = new PubsubClient();
