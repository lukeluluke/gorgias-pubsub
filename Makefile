all: build-subscriber
environment:
	cp .env.example.production publisher && cp .env.example.production subscriber
build-publisher:
	cd publisher && gcloud builds submit --config cloudbuild.yaml
build-subscriber:
	cd subscriber && gcloud builds submit --config cloudbuild.yaml
