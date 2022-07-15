DOCKER_MACHINE_NAME = gcmannb

VIRTUALBOX_CPU_COUNT ?= 2

# In MB
VIRTUALBOX_DISK_SIZE ?= 40000
VIRTUALBOX_MEMORY_SIZE ?= 2048

## Create docker machine
docker-machine/create:
	docker-machine create -d "virtualbox" $(DOCKER_MACHINE_NAME)