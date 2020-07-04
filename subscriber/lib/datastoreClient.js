const {Datastore} = require('@google-cloud/datastore');
require('dotenv').config()

class DatastoreClient {
    constructor() {
        this.projectId = process.env.PROJECT_ID;
        this.db = new Datastore({
            projectId: this.projectId
        });
    }

    async addTicket(ticket) {

        try {
            if (!ticket || typeof ticket !== 'object') {
                return new Error('Invalid ticket');
            }

           const ticketData = [];
            Object.entries(ticket).forEach(([key, val]) => {
                ticketData.push({
                    name: key,
                    value: val ? val : ''
                })
            });

            const ticketKey = this.db.key('Ticket');
            const entity = {
                key: ticketKey,
                data: ticketData
            };
            await this.db.save(entity);

            return ticketKey;
        } catch (e) {
            console.log(e);
            return new Error(`Unable to store ticket, error ${e.toString()}`)
        }
    }

}

module.exports = new DatastoreClient();
