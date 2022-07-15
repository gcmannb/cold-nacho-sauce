# Absolute directory of this Makfile
_MAKEFILE_DIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

include $(_MAKEFILE_DIR)/.mk/*.mk
