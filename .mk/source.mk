#: source code utilities

## Fix to ensure that files end with LF
fix/eof-new-line: -fix-eof-new-line

## Apply all fixes
fix: fix/eof-new-line

FILTER_REGEX_EXCLUDE=.*config/database.yml

## Run super linter locally
superlinter:
	$(Q) docker run -e RUN_LOCAL=true -v "$(shell pwd):/tmp/lint" github/super-linter

## Run super linter fixes
fix/superlinter:
	$(Q) docker run --entrypoint rubocop -e RUN_LOCAL=true -v "$(shell pwd):/tmp/lint" github/super-linter -a -c /action/lib/.automation/.ruby-lint.yml  '/tmp/lint/**/*.rb'


fix/superlinter/force:
	$(Q) docker run --entrypoint rubocop -e RUN_LOCAL=true -v "$(shell pwd):/tmp/lint" github/super-linter -A -c /action/lib/.automation/.ruby-lint.yml  '/tmp/lint/**/*.rb'


rufo:
	$(Q) docker run -it --rm -v $$(pwd):/opt/gembuild ruby:2.6 bash -c ' \
		gem install rufo; \
		cd /opt/gembuild; \
		rufo lib spec; \
	'