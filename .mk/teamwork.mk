#: teamwork: git and github, code sharing

.PHONY: \
	gh/pr \
	gh/team \
	tmux/xp \

## Print out GitHub team members
gh/team: -gh/team

## Create a draft PR
gh/pr: -gh/pr

## Start tmux session sharable with others (eXtreme Programming)
tmux/xp: -tmux/xp
