include ../config.mk

WWW_DIST=cgi-bin/acf\
	cgi-bin/mvc.lua\
	index.html\
	sample.html\
	static/alpine.jpg\
	static/alpine_inv.jpg\
	static/reset.css\
	static/watermark.jpg\
	static/prototype.js\
	static/tango/16x16/categories/applications-internet.png \
	static/tango/16x16/places/start-here.png \
	static/tango/16x16/places/network-server.png \
	static/tango/16x16/status/network*.png \
	static/tango/16x16/devices/computer.png \
	static/tango/16x16/apps/system-users.png \
	ice/* \
	snow/* \
	clouds/*

EXTRA_DIST=Makefile
DISTFILES=$(WWW_DIST) $(EXTRA_DIST)

install_dir=$(DESTDIR)/$(wwwdir)
dist_dir=$(DISTDIR)/$(notdir $(PWD))

phony+=all
all:

phony+=clean
clean:

phony+=distdir
distdir: $(DISTFILES)
	mkdir -p "$(dist_dir)"
	for i in $(DISTFILES); do\
		dest=`dirname "$(dist_dir)/$$i"`;\
		mkdir -p "$$dest";\
		cp "$$i" "$$dest";\
	done

phony+=install
install:
	mkdir -p $(install_dir)
	for i in $(WWW_DIST); do\
		dest=`dirname "$(install_dir)/$$i"`;\
		mkdir -p "$$dest";\
		cp "$$i" "$$dest";\
	done
	chmod +x $(install_dir)/cgi-bin/acf


.PHONY: $(phony)
