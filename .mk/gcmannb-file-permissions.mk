# gcmannb idiosyncrasy:
#
# Local nuc user and LDAP user could have different UIDs which makes permissions
# not work transparently inside the container

.PHONY: \
	-check-file-permissions

# Look for the docker user having ownership of a file, which causes problems
-check-file-permissions: -gcmannb-check-file-permissions
