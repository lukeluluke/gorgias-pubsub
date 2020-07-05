#Google Cloud Pub/Sub for Gorgias ticket event
This application will setup a Google cloud pub/sub service, which can listen for any tickets event from Gorgias, and 
publish event as message into Pub/Sub, then handle the ticket and save into Google Datastore

  
## Prerequites
- Google Cloud Account
- Google Cloud SDK [Doc](https://cloud.google.com/sdk/docs/quickstarts)
- Gorgias Account [Link](https://www.gorgias.com/)
- Node 12
- Yarn 
- Docker

## Deployment 

#### If you don't have a project yet
Now it is time for you to think about a name for your project
1. Update PROJECT_ID with your idea name of Makefile
    ```makefile
    PROJECT_ID := ***********
    ```
2. Create a project by running following
    ```makefile
    make create-project   
    ```   
   
#### Get your project details
1. Get `PROJECT_ID`, `PROJECT_NUMBER` and `ACCOUNT_ID` of you project, run following
    ```makefile
    make get-project-info
    ```
2. Update variable value of Makefile
    ```makefile
    PROJECT_ID := ***********
    PROJECT_NUMBER := ***********
    ACCOUNT_ID := ***********
    ```
3. Setup your project
    ```makefile
    make project-setup
    ```
#### Setup Cloud Datastore 
You will need to manually enable [Datastore](https://cloud.google.com/datastore) for you project crated above 

#### Setup Pub/Sub
1. You will need define following value in Makefile
    ```makefile
    #Region of you service e.g australia-southeast1 for Australia
    REGION := *********** 
    
    #Service account
    SERVICE_ACCOUNT_NAME := ***********
    
    #Topic for your pub/sub
    PUBSUB_TOPIC := ***********
    
    #Name for your subscriber
    PUBSUB_PULL_SUBSCRIBER := ***********
    
    #Secure your webhook which will be used by Gorgias
    VERIFICATION_TOKEN := ***********
    
    #http port for your webhook (8080)
    PUBLISHER_SERVICE_PORT := ***********
    
    #http port for your subscriber (8080)
    SUBSCRIBER_SERVICE_PORT := ***********
    
    #Timeout for you message subscriber (60)
    SUBSCRIPTION_TIMEOUT := ***********
    
    #The service name of you cloud run publisher
    PUBLISHER_SERVICE_NAME := ***********
    
    #Image name when build your publisher
    PUBLISHER_IMAGE := ***********
    
    #The service name of you cloud run subscriber
    SUBSCRIBER_SERVICE_NAME := ***********
    
    #Image name when build your subscriber
    SUBSCRIBER_IMAGE := ***********
    ```      
2. Build your pub/sub by running following:
    ```makefile
    make pubsub-setup   
    ```

#### Create cloud schedule task
Since we use pull subscriber, we will need to crete a schedule task to regularly pull new messages from pub/sub
1. Get service endpoints
    ```makefile
    make get-services-url
    ```   
2. Get url from output above, and update makefile
    ```makefile
   #Url of your subscriber service
   SUBSCRIBER_SERVICE_ENDPOINT := [url]
   
   #Schedule task name
   SCHEDULE_TASK := ***********
   
   #Frenquency of scheduler task, e.g. */10 * * * * (every 10 mins)
   SCHEDULE_TIME := */10 * * * *
    ```
3. Run 
    ```makefile
    make schedule-setup
    ```

Now you have your cloud PubSub service ready. 
#### Update publisher or Subscriber
If you make some change to you code of publisher and subscriber, you can easily re-build and deploy by runing 
```makefile
make build-service
```

## Setup Gorgias 
1. Get publisher service endpoint 
    ```makefile
    make get-services-url 
    ```
2. Create a http integration in Gorgias [Doc](https://docs.gorgias.com/data-and-http-integrations/http-integrations#segment)
    - Setup header with VERIFICATION_TOKEN (in Makefile)
    ```
     Authorization: Bearer [VERIFICATION_TOKEN]
    ```
    - Set Url with publisher service url `[url]/publish-ticket`  
    - Create Payload in request Body with information you need
    ```
        {
            "priority": "{{ticket.priority}}",
            "subject": "{{ticket.subject}}",
            "customer_name": "{{ticket.customer.name}}",
            "assignee_team_id": "{{ticket.assignee_team_id}}",
            "via": "{{ticket.via}}",
            "requester_name": "{{ticket.requester.name}}",
            "ticket_id": "{{ticket.id}}",
            "assignee_user_name": "{{ticket.assignee_user.name}}",
            "ticket_channel": "{{ticket.channel}}",
            "status": "{{ticket.status}}",
            "account_domain": "{{ticket.account.domain}}",
            "first_message": "{{ticket.first_message.body_text}}",
            "assignee_user_email": "{{ticket.assignee_user.email}}",
            "language": "{{ticket.language}}",
            "requester_email": "{{ticket.requester.email}}",
            "customer_email": "{{ticket.customer.email}}",
            "last_message": "{{ticket.last_message.body_text}}",
            "updated_datetime": "{{ticket.updated_datetime}}"
        }
    ```
3. Tick triggers you need
    - Ticket created
    - Ticket updated
    - Ticket message created
    
## Local development 
You can develop and test Pub/Sub service locally 
1. You need to have a project, you can refer to `Deployment ` for how to setup project

2. Setup service account
    * If you want to create new service account
    - Assign your idea account name to  `SERVICE_ACCOUNT_NAME` in `Makefile`
    - Run `make service-account` 
    
    Then follow steps:  
       - Login to your Google Cloud Platform console
       - Go to IAM & Admin, and then Service Accounts
       - Select the service account and create key
       - download key to project root folder and rename it to `key.json`  
              
3. Create a local  `.env` file, and update variables 
    ```
    cp .env.example .env
    ``` 
    if `TOPIC_NAME` and `SUBSCRIBER_NAME` can be existing one, or new name, give different `port` to publisher and subscribr
4. Build Project
    ```bash
    yarn run build
    ```    
5. Start Project, it will try to create new Topic and Subscriber
    ```bash
    yarn start
    ``` 
6. Open new terminals for publisher and subscriber , and start services
    ```bash
    yarn run start:publisher
    yarn run start:subscriber
    ```   
7. You can use http request tools to test e.g. `Postman`
    - Publisher webhook `http://localhost:8080/publish-ticket`
        - POST request
        - Setup header `Authorization: Bearer [VERIFICATION_TOKEN]`
        -  JSON payload, e.g.
            ```bash
               {
                   "ticket_id": "12345",
                   "subject": "test ticket"
               }
            ```
    - Subscriber url `http://localhost:8090/pull`
        - POST request
        - No authorization is needed for local test
        - No payload       
