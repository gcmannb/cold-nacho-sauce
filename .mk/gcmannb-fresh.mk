#: update gcmannb apps

## Get up-to-speed with various gcmannb apps
fresh:
	echo "Removed apps from fresh"

# gcmannb-specific Apache integration
-apache-integration-%:
	$(Q) bash -l -c 'cd $(SOURCE_DIR)/$* && rvm info && bundle install --full-index'
	$(Q) touch $(SOURCE_DIR)/$*/tmp/restart.txt
