# When make is run with VERBOSE=1, display more output.  By default, we suppress
# most output and only try to report status and problems
ifdef VERBOSE
Q=
SUPPRESS_OUTPUT=
SUPPRESS_ERROR_OUTPUT =
WARNING_OUTPUT = >&2
TRACE_OUTPUT = >&2
else
Q=@
SUPPRESS_OUTPUT = >/dev/null
SUPPRESS_ERROR_OUTPUT = 2>/dev/null
WARNING_OUTPUT = >&2  # always provided even when VERBOSE is off
TRACE_OUTPUT = >/dev/null
endif

ifdef DRY_RUN
$(warning dry run:)
Q=@echo
endif

ORG=gcmannb

# Various project directories
SOURCE_DIR = $(HOME)/source

_RED = \x1b[31m
_GREEN = \x1b[32m
_YELLOW = \x1b[33m
_CYAN = \x1b[34m
_RESET = \x1b[0m

_WARNING=$(_YELLOW)warning $(_RESET)
_OK=$(_GREEN)ok $(_RESET)

UNAME := $(shell uname -s)

_CREDENTIALS_FILE=(Investigate setting up credentials in .mk/_credentials.mk)

include $(_MAKEFILE_DIR)/.mk/$(ORG)/_variables.mk
-include $(_MAKEFILE_DIR)/.mk/_credentials.mk
