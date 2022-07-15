#: start, stop docker/docker-compose
#
# Provides recipes for local development using docker-compose.  Use of this
# file is not required and can serve as a reference.
#
# The bare commands `docker-compose` and `docker` are likely to run into issues
# with permissions and host names, so these recipes ensure that these commands
# are invoked correctly and provide some safeguards.
#

# Maximize compatibility by using bash, and not sh or dash
SHELL = /usr/bin/env bash

DOCKER_COMPOSE_VERSION_EXPECTED = 1.20
AWS_ACCOUNT_ID = OK

RAILS_ENV ?= development
_UNAME := $(shell uname -s)

ifeq ($(_UNAME),Darwin)
# These workarounds don't appear to be required on macOS
else

# Bridge together host and guest user and group IDs so that file permissions
# work transparently to docker (similar to https://vsupalov.com/docker-shared-permissions/)
#
HOST_GUEST_ENV_VARS = \
	HOST_UID=$(shell stat -c%u .) \
	HOST_OWNER=$(shell stat -c%u:%g .)
DOCKER_COMPOSE_BUILD_ARGS = \
	--build-arg HOST_UID=$(shell id -u) \
	--build-arg HOST_OWNER=$(shell stat -c%u:%g .) \
	--parallel
# 	\
# 	COMPOSE_DOCKER_CLI_BUILD=1 \
# 	DOCKER_BUILDKIT=1
endif

PROJECT_ENV_VARS = -e AWS_ACCESS_KEY_ID=$(shell aws configure get aws_access_key_id) \
    -e AWS_SECRET_ACCESS_KEY=$(shell aws configure get aws_secret_access_key) \
    -e RAILS_ENV=$(RAILS_ENV)

# For the currently running container, get the RAILS_ENV
_UP_WITH_RAILS_ENV = $(shell docker-compose exec $(PROJECT) printenv | sed -nE 's/RAILS_ENV=(.+)/\1/p' )
_DOCKER_COMPOSE_VERSION = $(shell docker-compose version | sed -nE 's/docker-compose version ([0-9.]+).*/\1/p')

# Detect how much disk space is in use by Docker to prevent issues starting containers
_THRESHOLD_DEVMAPPER := 88  # in percent

_DEVMAPPER_SPACE_USED = $(shell df --output=pcent /dev/mapper/* | \
	tail -n +2 | tr -d '% ' | sort -nr | head -1)

.PHONY: \
	-check-docker-compose-version \
	-flight-checks \
	-check-devicemapper-disk-space \
	-must-be-up \
	-must-be-up-with-test \
	-show-listening-services \
	-up \
	$(PROJECT)/seed \
	bash \
	build \
	console \
	db\:reset \
	down \
	fixtures/load \
	login \
	old/spec \
	prune \
	restart \
	run/bash \
	run/console \
	run/db\:migrate \
	run/spec \
	spec \
	up \

## Build with the proper environment and args specified
build: -check-docker-compose-version
	$(Q) $(HOST_GUEST_ENV_VARS) RAILS_ENV=$(RAILS_ENV) docker-compose build $(DOCKER_COMPOSE_BUILD_ARGS) $(SUPPRESS_OUTPUT)

# Depend upon build to ensure that the image was built correctly with the
# variables
## Bring up the compose services
up: | down build -up -show-listening-services

-up:
	$(Q) $(HOST_GUEST_ENV_VARS) RAILS_ENV=$(RAILS_ENV) docker-compose up -d	$(SUPPRESS_OUTPUT)

## Take down the compose services
down:
	$(Q) docker-compose down $(SUPPRESS_OUTPUT)

## Restart puma
restart:
	$(Q) docker-compose exec $(PROJECT) bundle exec pumactl -P /home/appuser/tmp/pids/server.pid restart

## Run rails console (using a running container)
console: -must-be-up
	$(Q) docker-compose exec $(PROJECT_ENV_VARS) $(PROJECT) rails console

## Run rails console (one-off container)
run/console: build
	$(Q) $(HOST_GUEST_ENV_VARS) docker-compose run $(PROJECT_ENV_VARS) $(PROJECT) rails console

## Run bundle install  (one-off container)
run/bundle: build
	$(Q) $(HOST_GUEST_ENV_VARS) docker-compose run $(PROJECT_ENV_VARS) $(PROJECT) bundle install

## Load fixtures
fixtures/load: -must-be-up
	$(Q) docker-compose exec $(PROJECT_ENV_VARS) $(PROJECT) bundle exec rake db:fixtures:load FIXTURES_PATH=spec/fixtures

## Run bash shell (using a running container)
bash: -must-be-up
	$(Q) docker-compose exec $(PROJECT_ENV_VARS) $(PROJECT) bash
## Run bash shell (one-off container)
run/bash: build
	$(Q) docker-compose run $(PROJECT_ENV_VARS) $(PROJECT) bash

## Run rake tasks
rake/%: -must-be-up
	$(Q) docker-compose exec $(PROJECT_ENV_VARS) $(PROJECT) bundle exec rake $*

old/spec:
	bundle exec rake spec SPEC="./spec/mailers/connection_mailer_spec.rb ./spec/mailers/payment_mailer_spec.rb ./spec/mailers/reminder_mailer_spec.rb spec/actions/user_canceled_spec.rb"

## Execute specs (using a running container)
spec: -must-be-up-with-test
	$(Q) cat spec.sh | docker-compose exec $(PROJECT_ENV_VARS) -T -e RAILS_LOG_TO_STDOUT= -e RAILS_ENV=test $(PROJECT) bash
## Execute specs (one-off container)
run/spec:
	$(Q) cat spec.sh | docker-compose run $(PROJECT_ENV_VARS) -T -e RAILS_LOG_TO_STDOUT= -e RAILS_ENV=test $(PROJECT) bash

# run/spec: build
# 	$(Q) docker-compose run $(PROJECT_ENV_VARS) $(PROJECT) bash
.PHONY: db\:migrate db\:status
db\:migrate: -must-be-up
	$(Q) docker-compose exec $(PROJECT_ENV_VARS) $(PROJECT) bundle exec rake db:migrate RAILS_ENV=development

db\:status: -must-be-up
	$(Q) docker-compose exec $(PROJECT_ENV_VARS) $(PROJECT) bundle exec rake db:status RAILS_ENV=development

## Run DB migrations (one-off container)
run/db\:migrate:
	$(Q) docker-compose run $(PROJECT_ENV_VARS) $(PROJECT) bundle exec rake db:migrate RAILS_ENV=test

## Execute rake db:reset
db\:reset: -must-be-up
	$(Q) docker-compose exec $(PROJECT_ENV_VARS) $(PROJECT) bundle exec rake db:reset

## Login for ECR access
login:
	$(Q) aws ecr get-login-password \
	    --region us-east-1 \
	| docker login \
	    --username AWS \
	    --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com

## Seed database (Zip codes)
tree/seed:
	$(Q) docker-compose run --rm \
		-v $(SEED_FILE):/tmp/db.csv \
		tree bundle exec rake bin:update_zipcodes[/tmp/db.csv]

-checks: \
	-check-file-permissions \
	-show-listening-services \

-preflight-checks: \
	-check-docker-compose-version \

-non-darwin-preflight-checks: \
	-check-devicemapper-disk-space

## Cleanup docker
prune:
	$(Q) docker rm $$(docker ps -q -f 'status=exited')
	$(Q) docker rmi $$(docker images -q -f "dangling=true")

# Check docker compose version is 1.20 which is used by CI
-check-docker-compose-version:
	@ if [[ "$(_DOCKER_COMPOSE_VERSION)" != *"$(DOCKER_COMPOSE_VERSION_EXPECTED)"* ]]; then \
		printf "$(_WARNING) unexpected version of docker-compose, $(_DOCKER_COMPOSE_VERSION) (expected: $(DOCKER_COMPOSE_VERSION_EXPECTED))\n" $(WARNING_OUTPUT); \
	fi

-check-devicemapper-disk-space:
	@ if [[ $(_DEVMAPPER_SPACE_USED) -gt $(_THRESHOLD_DEVMAPPER) ]]; then \
		printf "$(_WARNING) low disk space available to docker ($(_DEVMAPPER_SPACE_USED)%% used)\n" $(WARNING_OUTPUT); \
	else \
		printf "$(_OK) disk space available to docker ($(_DEVMAPPER_SPACE_USED)%% used)\n" $(TRACE_OUTPUT); \
	fi

-must-be-up:
	@ if [ -z $$(docker-compose ps -q $(PROJECT)) ] || [ -z $$(docker ps -q --no-trunc | grep $$(docker-compose ps -q $(PROJECT))) ]; then \
		echo "$(PROJECT) is not running (Try running \`make up\` first or use the \`run/\` variant for a one off container) "; \
		exit 1; \
	fi

-must-be-up-with-test: -must-be-up
	@ if [[ $(_UP_WITH_RAILS_ENV) != 'test' ]]; then \
		echo "$(PROJECT) is not running the correct environment for this to work (Try using the \`run/\` variant for a one off container in the test environment) "; \
		exit 1; \
	fi
