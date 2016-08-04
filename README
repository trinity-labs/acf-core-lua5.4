Alpine Configuration Framework

To install the package run:

  make install

To set up mini_httpd create a /etc/mini_httpd.conf file containing:
nochroot
dir=/usr/share/acf/www
user=nobody
logfile=/var/log/mini_httpd.log
cgipat=cgi-bin/*
#host=<ip-addr>

Then start mini_httpd with:

  mini_httpd -C /etc/mini_httpd.conf
