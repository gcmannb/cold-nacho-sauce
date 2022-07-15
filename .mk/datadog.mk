#: datadog apis

_NOW_EPOCH_SECONDS = $(shell date +%s)
_UNAME = $(shell uname -s)

ifeq ($(_UNAME),Darwin)
_T-1HR_EPOCH_SECONDS = $(shell date -v-1H +%s)
else
_T-1HR_EPOCH_SECONDS = $(shell date +%s -d "1 hour ago")
endif


DD_QUERY = trace-analytics("env:prod service:hi-welt").rollup("pc75", "@duration").last("15m") > 20000000000

dd_query_encoded = $(shell echo "console.log(encodeURIComponent('$(DD_QUERY)'))" | node - )

datadog/query: -require-datadog-env
	$(Q) curl -H "DD-API-KEY: $(DD_API_KEY)" \
		-H "DD-APPLICATION-KEY: $(DD_APPLICATION_KEY)" \
		-H "Content-Type: application/json" \
		-X GET "https://api.datadoghq.com/api/v1/query?from=$(_T-1HR_EPOCH_SECONDS)&to=$(_NOW_EPOCH_SECONDS)&query=$(dd_query_encoded)"

doctor: datadog/doctor

## Diagnose issues with datadog
datadog/doctor: -check-datadog-credentials

-check-datadog-credentials:
	@ if [[ -z "$${DD_API_KEY}" ]]; then \
		printf >&2 "$(_YELLOW)warning$(_RESET): no Datadog API key set $(_CREDENTIALS_FILE)\n"; \
	fi
	@ if [[ -z "$${DD_APPLICATION_KEY}" ]]; then \
		printf >&2 "$(_YELLOW)warning$(_RESET): no Datadog application key set $(_CREDENTIALS_FILE)\n"; \
	fi

-require-datadog-env: -check-env-DD_APPLICATION_KEY -check-env-DD_API_KEY