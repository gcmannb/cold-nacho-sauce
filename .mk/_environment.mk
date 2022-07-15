_DEV_MESSAGE=(Have you tried 'nacho doctor'?)
-check-command-%:
	@ if [ ! $(shell command -v "${*}" ) ]; then \
		echo "Command ${*} could not be found $(_DEV_MESSAGE)"; \
		exit 1; \
	fi

-suggest-env-%:
	@ if [ "${${*}}" = "" ]; then \
		printf >&2 "$(_CYAN)tip:$(_RESET) Environment variable ${*} not set\n"; \
	fi

-check-env-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable ${*} not set $(_DEV_MESSAGE)"; \
		exit 1; \
	fi
