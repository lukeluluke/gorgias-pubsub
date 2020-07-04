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
            if (!ticket) {
                return new Error('Invalid ticket');
            }

            const ticketKey = this.db.key('Ticket');
            const entity = {
                key: ticketKey,
                data: [
                    {
                        name: 'id',
                        value: ticket.ticket_id
                    }
                ]
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
