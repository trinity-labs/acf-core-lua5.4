include ../config.mk

APP_DIST= \
	acf-util/acf-util.roles \
	acf-util/logon-controller.lua \
	acf-util/logon-model.lua \
	acf-util/password-controller.lua \
	acf-util/password-model.lua \
	acf-util/password-status-html.lsp \
	acf-util/password.menu \
	acf-util/roles-controller.lua \
	acf-util/roles-getpermslist-html.lsp \
	acf-util/roles-model.lua \
	acf-util/roles-read-html.lsp \
	acf-util/roles-viewroleperms-html.lsp \
	acf-util/roles-viewroles-html.lsp \
	acf-util/roles-viewuserroles-html.lsp \
	acf-util/roles.menu \
	acf-util/skins-controller.lua \
	acf-util/skins-model.lua \
	acf-util/skins.menu \
	acf-util/welcome-controller.lua\
	acf-util/welcome-html.lsp\
	acf_www-controller.lua\
	acf_cli-controller.lua\
	menuhints.menu\
	template-json.lsp\
	template-html.lsp\
	template-stream.lsp\
	dispatcherror-html.lsp\
	exception-html.lsp\
	status-html.lsp\
	filedetails-html.lsp\
	expert-html.lsp\
	debug-html.lsp\
	logfile-html.lsp\

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
