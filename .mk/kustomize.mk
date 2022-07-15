#: kubernetes and kustomization

KUSTOMIZE = $(HOME)/Downloads/kustomize_1.0.5_darwin_amd64

NAMESPACE ?= greek
APPLICATION_K8S_CONTEXT ?= $(shell cat .k8s_context | tr -d ' ')

## Build kustomization YAML from files
kustomize/build: -check-env-NAMESPACE -check-env-APPLICATION_K8S_CONTEXT
	@ echo "APPLICATION_K8S_CONTEXT=$(APPLICATION_K8S_CONTEXT)"
	$(Q) AWS_DEFAULT_OUTPUT=json $(KUSTOMIZE) build config/deployment/overlays/$(NAMESPACE)

kustomize/test-generators: | -check-env-NAMESPACE -check-env-APPLICATION_K8S_CONTEXT -kustomize-test-generators

# TODO Actually check version

-check-kustomize-version:
	@ $(KUSTOMIZE) version
