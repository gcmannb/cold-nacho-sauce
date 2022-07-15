#: manage Apache server

## Restart Apache server
apache/restart:
	$(Q) sudo /etc/init.d/apache2 restart
