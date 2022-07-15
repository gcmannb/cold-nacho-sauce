#: local kubernetes cluster (kind)
#
# Using kind to run a local Kubernetes cluster
#

.PHONY: \
	-create-cluster \
	-ensure-docker-running \
	-go-get-kind \
	docker/network-range \
	install/kind \
	kind/add-ingress \
	kind/hosts/update \

## Install kind and create local k8s cluster
install/kind: -ensure-docker-running -go-get-kind -create-cluster

-go-get-kind:
	GO111MODULE="on" go get sigs.k8s.io/kind@v0.9.0

-create-cluster:
	./create-cluster.sh

## Update the host list to alias ingress server (requires password)
kind/hosts/update:
	sudo -- sh -c "echo 127.0.0.1 garymtest.com >> /etc/hosts"

## Install the ingress controller in the kind cluster
kind/add-ingress:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

-ensure-docker-running:
	$(Q) docker info > /dev/null

## Print out the docker network range used by docker machine
docker/network-range:
	docker network inspect kind -f "{{(index .IPAM.Config 0).Subnet}}" | cut -d '.' -f1,2
