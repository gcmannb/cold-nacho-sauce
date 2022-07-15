#: database utility
#

annotate:
	$(Q) docker-compose run --rm $(PROJECT) bundle exec annotate --position before --show-indexes
