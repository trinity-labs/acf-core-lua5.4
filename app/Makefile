include ../config.mk

APP_DIST= acf-util/logon-controller.lua\
	acf-util/logon-html.lsp\
	acf-util/logon-status-html.lsp\
	acf-util/logon-logout-html.lsp\
	acf-util/logon-model.lua\
	acf_www-controller.lua\
	cfgfile-model.lua\
	service-model.lua\
	menuhints.menu\
	template-html.lsp\
	welcome-controller.lua\
	welcome-html.lsp

EXTRA_DIST=README Makefile
DISTFILES=$(APP_DIST) $(EXTRA_DIST)

install_dir=$(DESTDIR)/$(appdir)

phony+=all
all:

phony+=clean
clean:

phony+=distdir
distdir: $(DISTFILES)
	mkdir -p "$(DISTDIR)/app"
	for i in $(DISTFILES); do\
		dest=`dirname "$(DISTDIR)/app/$$i"`;\
		mkdir -p "$$dest";\
		cp "$$i" "$$dest";\
	done

phony+=install
install:
	mkdir -p $(install_dir)
	for i in $(APP_DIST); do\
		dest=`dirname "$(install_dir)/$$i"`;\
		mkdir -p "$$dest";\
		cp "$$i" "$$dest";\
	done


.PHONY: $(phony)
