.PHONY: help \
	list \
	update \
	doctor \

_AWK_VERSION = $(shell awk --version)

# Show help when no other goal is specified
.DEFAULT_GOAL = help

## Show this help screen
help:
	@ if [[ "$(_AWK_VERSION)" == *"GNU Awk"* ]]; then \
		awk -f $(_MAKEFILE_DIR)/.mk/awk/makefile-help-screen.awk $(MAKEFILE_LIST); \
	else \
		awk -f $(_MAKEFILE_DIR)/.mk/awk/makefile-simple-help-screen.awk $(MAKEFILE_LIST) | sort; \
	fi

## List all targets
list:
	@ awk -f $(_MAKEFILE_DIR)/.mk/awk/makefile-list-targets.awk $(MAKEFILE_LIST) | grep -vE '^\.' | uniq | sort

## Update nacho itself to lastest version
update: -update-sources-nacho-sauce

## Diagnose common issues
doctor: \
	-checks \
	-preflight-checks \

# "slow" checks used by doctor
-checks:

# "fast" checks that are implied on any nacho command
-preflight-checks:

# macOS-specific checks (or not)
-darwin-preflight-checks:
-non-darwin-preflight-checks:

ifeq ($(_UNAME),Darwin)
-preflight-checks: -darwin-preflight-checks
else
-preflight-checks: -non-darwin-preflight-checks
endif
