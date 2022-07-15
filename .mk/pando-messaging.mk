#: pando messaging

## Check status of event consumer
event/status: -must-be-up
	$(Q) docker-compose exec $(PROJECT_ENV_VARS) $(PROJECT) bundle exec event_consumer status
