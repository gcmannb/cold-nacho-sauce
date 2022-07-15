.PHONY: \
	-check-aws-credentials

-checks: \
	-check-aws-credentials \

-check-aws-credentials:
	@ if [[ -z "$(shell aws configure get aws_access_key_id)" ]]; then \
		printf "$(_WARNING) no AWS credentials set\n" $(WARNING_OUTPUT); \
	else \
		printf "$(_OK) AWS credentials set\n" $(TRACE_OUTPUT); \
	fi
