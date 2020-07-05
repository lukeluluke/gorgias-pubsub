PROJECT_ID := gorgias-pubsub-test3
PROJECT_NUMBER := 102688730062
ACCOUNT_ID := 018052-ACD5CB-B3D84A
REGION := australia-southeast1
SERVICE_ACCOUNT_NAME := gorgias-pubsub-user4
PUBSUB_TOPIC := gorgias-ticket-3
PUBSUB_PULL_SUBSCRIBER := gorgias-ticket-subscriber-3
VERIFICATION_TOKEN := *******************
SUBSCRIPTION_TIMEOUT := 60
PUBLISHER_SERVICE_NAME := gorgias-publisher-3
PUBLISHER_IMAGE := gorgias-publisher-3
SUBSCRIBER_SERVICE_NAME := gorgias-subscriber-3
SUBSCRIBER_IMAGE := gorgias-subscriber-3
SUBSCRIBER_SERVICE_ENDPOINT := https://gorgias-subscriber-3-y3rlwm2ofq-ts.a.run.app/
SCHEDULE_TASK := gorgias-pubsub-schedule3
SCHEDULE_TIME := */10 * * * *

.PHONY: all
All: project-setup pubsub-setup schedule-setup

#Setup gcloud cli
project-setup: set-project link-billing

#Create PubSub, add service account, assign required roles, enable required services, build and deploy
pubsub-setup: create-service-account add-roles create-pubsub enable-services add-cloud-build-role create-env build-publisher build-subscriber

#Rebuild docker container and deploy
build-service: create-env build-publisher build-subscriber

#Create new service account
service-account: create-service-account add-roles

#Setup scheduler task
schedule-setup: create-scheduler

create-env:
	rm -r .env
	echo 'PROJECT_ID=$(PROJECT_ID)' >> .env
	echo 'TOPIC_NAME=$(PUBSUB_TOPIC)' >> .env
	echo 'SUBSCRIBER_NAME=$(PUBSUB_PULL_SUBSCRIBER)' >> .env
	echo 'VERIFICATION_TOKEN=$(VERIFICATION_TOKEN)' >> .env
	echo 'SUBSCRIPTION_TIMEOUT=$(SUBSCRIPTION_TIMEOUT)' >> .env
	#Add environment vars of production
	cp .env publisher/.env.example.production && cp .env subscriber/.env.example.production

get-project-info:
	#List Projects
	gcloud projects list
	#Get list of bill accounts
	gcloud alpha billing accounts list

create-project:
	#create new project
	gcloud projects create $(PROJECT_ID)
	#describe created project
	gcloud projects describe $(PROJECT_ID)

set-project:
	#Set the project for the current session
	gcloud config set project $(PROJECT_ID)

#setup local dev environment
set-local-dev: service-account
	#cloud pub/sub admin api
	gcloud services enable pubsub.googleapis.com

link-billing:
	#Link billing account to project
	gcloud alpha billing accounts projects link $(PROJECT_ID) --account-id=$(ACCOUNT_ID)
	# Confirm billing account has been linked
	gcloud beta billing accounts --project=$(PROJECT_ID) list

create-service-account:
	#create service account
	gcloud iam service-accounts create $(SERVICE_ACCOUNT_NAME) --description="service account" --display-name=$(SERVICE_ACCOUNT_NAME)
	#Show service account info
    #gcloud iam service-accounts describe $(SERVICE_ACCOUNT_NAME)@$(PROJECT_ID).iam.gserviceaccount.com
	gcloud iam service-accounts describe $(SERVICE_ACCOUNT_NAME)@$(PROJECT_ID).iam.gserviceaccount.com

add-roles:
	#PUB/SUB admin
	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
        --member=serviceAccount:$(SERVICE_ACCOUNT_NAME)@$(PROJECT_ID).iam.gserviceaccount.com --role=roles/pubsub.admin
    #Datastore user
	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
            --member=serviceAccount:$(SERVICE_ACCOUNT_NAME)@$(PROJECT_ID).iam.gserviceaccount.com --role=roles/datastore.user
    #Cloud run invoker
	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
			--member=serviceAccount:$(SERVICE_ACCOUNT_NAME)@$(PROJECT_ID).iam.gserviceaccount.com --role=roles/run.invoker
	#Scheduler admin
	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
			--member=serviceAccount:$(SERVICE_ACCOUNT_NAME)@$(PROJECT_ID).iam.gserviceaccount.com --role=roles/cloudscheduler.admin
	#Service account user
	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
    			--member=serviceAccount:$(SERVICE_ACCOUNT_NAME)@$(PROJECT_ID).iam.gserviceaccount.com --role=roles/iam.serviceAccountUser

create-pubsub:
	#create a topic of pub/sub
	gcloud pubsub topics create $(PUBSUB_TOPIC)
	#list topic
	gcloud pubsub topics list
	#create a pull subscriber
	gcloud pubsub subscriptions create $(PUBSUB_PULL_SUBSCRIBER) --topic=$(PUBSUB_TOPIC)
	#list subscribers
	gcloud pubsub subscriptions list

enable-services:
	#cloud pub/sub admin api
	gcloud services enable pubsub.googleapis.com
	#cloud build admin api
	gcloud services enable cloudbuild.googleapis.com
	#pp engine admin api
	gcloud services enable appengine.googleapis.com
	#cloud run admin api
	gcloud services enable run.googleapis.com
	#cloud scheduler
	gcloud services enable cloudscheduler.googleapis.com
	#datastore
	gcloud services enable datastore.googleapis.com

add-cloud-build-role:
	#cloud run admin
	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
    			--member=serviceAccount:$(PROJECT_NUMBER)@cloudbuild.gserviceaccount.com --role=roles/run.admin
    #Service account
	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
        		--member=serviceAccount:$(PROJECT_NUMBER)@cloudbuild.gserviceaccount.com --role=roles/iam.serviceAccountUser
build-publisher:
	#build publisher service
	cd publisher && gcloud builds submit --config cloudbuild.yaml \
		--substitutions=_IMAGE_NAME=$(PUBLISHER_IMAGE),_REGION=$(REGION),_SERVICE_NAME=$(PUBLISHER_SERVICE_NAME),_SERVICE_ACCOUNT=$(SERVICE_ACCOUNT_NAME)

build-subscriber:
	#build subscriber service
	cd subscriber && gcloud builds submit --config cloudbuild.yaml \
		--substitutions=_IMAGE_NAME=$(SUBSCRIBER_IMAGE),_REGION=$(REGION),_SERVICE_NAME=$(SUBSCRIBER_SERVICE_NAME),_SERVICE_ACCOUNT=$(SERVICE_ACCOUNT_NAME)

get-services-url:
	#Get endpoint for your publisher and subscriber services
	gcloud run services list --platform managed

create-scheduler:
	#Creaee app
	gcloud app create --region=$(REGION)
	#Crete scheduler task
	gcloud beta scheduler jobs create http $(SCHEDULE_TASK) --schedule "$(SCHEDULE_TIME)" \
       	--http-method=POST \
       	--uri=$(SUBSCRIBER_SERVICE_ENDPOINT)pull \
       	--oidc-service-account-email=$(SERVICE_ACCOUNT_NAME)@$(PROJECT_ID).iam.gserviceaccount.com   \
       	--oidc-token-audience=$(SUBSCRIBER_SERVICE_ENDPOINT)pull

