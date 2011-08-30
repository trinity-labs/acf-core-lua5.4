include ../config.mk

LUA_DIST=mvc.lua\

EXTRA_DIST=Makefile
DISTFILES=$(LUA_DIST) $(EXTRA_DIST)

install_dir=$(DESTDIR)/$(luadir)
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
	for i in $(LUA_DIST); do\
		dest=`dirname "$(install_dir)/$$i"`;\
		mkdir -p "$$dest";\
		cp "$$i" "$$dest";\
	done

.PHONY: $(phony)
