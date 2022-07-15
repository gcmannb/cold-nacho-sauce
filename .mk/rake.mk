#: proxies for rake tasks (autodetect context)

.PHONY: \
	-docker-routes \
	-apache-routes \
	routes \

.SECONDEXPANSION:

## Display rake routes
routes: -$$(GCMANNB_CONTEXT)-routes

-docker-routes: -must-be-up
	$(Q) docker-compose exec $(APP_ENV_VARS) $(PROJECT) bundle exec rake routes

-apache-routes:
	$(Q) rake routes

