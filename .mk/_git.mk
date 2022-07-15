# Module for working with Git, GitHub
-gh/team:
	$(Q) echo $(PROJECT_REVIEWERS)

-gh/pr:
	$(Q) gh pr create -d -a gcmannb $(foreach r,$(PROJECT_REVIEWERS),-r $(r))

# Update given source directory
-update-sources-%:
	$(Q) $(NACHO_BIN_DIR)/update-sources-helper $(SOURCE_DIR)/$*
