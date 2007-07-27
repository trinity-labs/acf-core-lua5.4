include ../config.mk

WWW_DIST=cgi-bin/acf\
	cgi-bin/mvc.lua\
	static/alpine.gif\
	static/alpine.png\
	static/arctic-back.png\
	static/arctic-upleft.png\
	static/greypx.gif\
	static/selected.gif\
	static/submenu.css\
	static/unselected.gif\
	static/webconf-purple.css\
	static/webconf.css\
	index.html\
	sample.html

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
