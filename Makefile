APP_NAME=core
PACKAGE=acf-$(APP_NAME)
VERSION=0.16.1

P=$(PACKAGE)-$(VERSION)
DISTDIR:=$(shell pwd)/$(P)
DISTPKG=$(P).tar.bz2

SUBDIRS=app bin lib lua www
EXTRA_DIST=config.mk Makefile README
CONF_FILES=acf.conf
LOGROTATE_FILES=acf

DISTFILES=$(EXTRA_DIST) $(CONF_FILES) $(LOGROTATE_FILES)

CP=cp
TAR=tar

RECURSIVE_TARGETS=all-recursive install-recursive distdir-recursive \
	clean-recursive
phony+=$(RECURSIVE_TARGETS)

export DISTDIR DESTDIR
$(RECURSIVE_TARGETS):
	target=`echo $@ | sed 's/-recursive//'`;\
	for dir in $(SUBDIRS); do\
		( cd $$dir && $(MAKE) $$target ) || exit 1;\
	done

phony += all
all:	all-recursive

phony += clean
clean:	clean-recursive
	rm -rf $(DISTDIR) $(DISTPKG)

phony += distdir
distdir: distdir-recursive $(DISTFILES)
	for i in $(DISTFILES) ; do\
		dest="$(DISTDIR)/$$i";\
		mkdir -p `dirname $$dest` &&\
		$(CP) "$$i" "$$dest" || exit 1;\
	done

phony += dist
dist: 	$(DISTPKG)

$(DISTPKG): distdir $(DISTFILES)
	$(TAR) -chjf $@ $(P)
	rm -r $(DISTDIR)

phony+=install
install: install-recursive $(CONF_FILES)
	mkdir -p $(DESTDIR)/etc/acf
	cp $(CONF_FILES) $(DESTDIR)/etc/acf
	mkdir -p $(DESTDIR)/etc/logrotate.d
	cp $(LOGROTATE_FILES) $(DESTDIR)/etc/logrotate.d
	ln -sf /etc/acf/skins $(DESTDIR)/$(wwwdir)/userskins

include config.mk

.PHONY: $(phony)
