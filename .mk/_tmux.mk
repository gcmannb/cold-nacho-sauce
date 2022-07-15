# Module for working with tmux

-tmux/xp:
	@ echo "To attach (read-only for driver): tmux -S /tmp/extreme attach -t shared -r"
	@ echo "Press ENTER to continue..."
	@ read
	$(Q) /usr/bin/tmux -S /tmp/extreme new -s shared
	$(Q) chgrp $(TEAM_GROUP_NAME) /tmp/extreme
