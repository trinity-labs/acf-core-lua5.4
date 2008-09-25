include ../config.mk

LIB_DIST=fs.lua\
	html.lua\
	date.lua\
	format.lua\
	menubuilder.lua\
	procps.lua\
	session.lua\
	validator.lua\
	authenticator.lua\
	authenticator-plaintext.lua\
	daemoncontrol.lua\
	getopts.lua\
	roles.lua\
	processinfo.lua\
	viewfunctions.lua\
	controllerfunctions.lua\
	modelfunctions.lua\
	cfe.lua\
	apk.lua\

EXTRA_DIST=README Makefile
DISTFILES=$(LIB_DIST) $(EXTRA_DIST)

install_dir=$(DESTDIR)/$(acflibdir)
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
	for i in $(LIB_DIST); do\
		dest=`dirname "$(install_dir)/$$i"`;\
		mkdir -p "$$dest";\
		cp "$$i" "$$dest";\
	done


.PHONY: $(phony)
