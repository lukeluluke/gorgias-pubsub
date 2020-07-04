all: environment build-publisher
environment:
	cp .env.example.production publisher && cp .env.example.production subscriber
build-publisher:
	cd publisher && gcloud builds submit --config cloudbuild.yaml
