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
	static/tango/16x16/actions/* \
	static/tango/16x16/animations/* \
	static/tango/16x16/apps/* \
	static/tango/16x16/categories/* \
	static/tango/16x16/devices/* \
	static/tango/16x16/emblems/* \
	static/tango/16x16/emotes/* \
	static/tango/16x16/mimetypes/* \
	static/tango/16x16/places/* \
	static/tango/16x16/status/* \
	ice/* \
	snow/*

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
