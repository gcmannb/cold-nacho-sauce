#: gcmannb workplace

## Connect to gcmannb VPN
vpn: -require-darwin -suggest-env-VPN_CREDENTIALS
	$(Q) scutil --nc start "gcmannb.example.com" $(VPN_CREDENTIALS)

-require-darwin:
	@ if [[ $(UNAME) != "Darwin" ]]; then \
		printf >&2 "$(_RED)error$(_RESET): command only works on macOS \n"; \
	fi