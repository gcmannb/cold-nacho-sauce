#: jira

ME_EMAIL=gcmannb@example.com
JIRA_PROJECT=HASBEEN
RELEASE=yday

## Current release (app name)
-%/release:
	$(Q) jira list -q "fixVersion=$(RELEASE) and component in ($*)"

## Team status
-%/team:
	$(Q) jira list -q 'project = "$(JIRA_PROJECT)" and component in ($*) and assignee in ("") and status not in ()'

# TODO Assignees and gcmannb-specific statuses removed

# TODO Apps and teams were removed
example/release: -example/release
example/team: -example/team
example/sprint: -example/sprint

open:
	$(Q) jira list -q 'project = "$(JIRA_PROJECT)" and development[pullrequests].open > 0'

ready:
	$(Q) jira list -q 'project = "$(JIRA_PROJECT)" and development[pullrequests].open > 0 and fixVersion=$(RELEASE)'

## Team status
me:
	$(Q) jira list -q 'assignee = "$(ME_EMAIL)"'
