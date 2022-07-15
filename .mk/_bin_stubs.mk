#
# Sometimes a script is too long or complicated to add to
# a make target itself, so this file recommends a pattern
# for delegating to scripts located in this bin directory
#

ifdef AGGRESSIVE
_AFFECTED_FILES = $(shell git ls-files 2> /dev/null)
else
_AFFECTED_FILES = $(shell git diff --name-only 2> /dev/null)
endif

export PYTHON=python3
NACHO_BIN_DIR = $(_MAKEFILE_DIR)/bin/

.PHONY: \
	-check-file-permissions \
	-fix-eof-new-line \
	-kustomize-test-generators \
	-show-listening-services \

-check-file-permissions:
	@ $(NACHO_BIN_DIR)/check-file-permissions

-show-listening-services:
	@ $(NACHO_BIN_DIR)/show-listening-services

-fix-eof-new-line:
	@ $(NACHO_BIN_DIR)/fix-eof-new-line $(_AFFECTED_FILES)

-kustomize-test-generators:
	@ $(NACHO_BIN_DIR)/kustomize-test-generators
