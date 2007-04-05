# acf.mk

ACF_MK_VERSION 	=0.2

SUBDIR		=$(basename $(PWD))
DISTDIR 	?=$(PV)
PV		=${PACKAGE}-${VERSION}
DISTFILES	=$(APP_DIST) $(LIB_DIST) $(ETC_DIST) $(CGI_DIST) $(WWW_DIST)\
		$(STATIC_DIST) $(EXTRA_DIST)
TARBZ2		=$(PV).tar.bz2
DISTPKG		=$(TARBZ2)

CP		=cp
MKDIR		=mkdir
TAR		=tar

MAKEFLAGS 	+= --no-print-directory --quiet
RECURSIVE_TARGETS = $(addsuffix -recursive,all clean distdir install)

phony += all
all:	all-recursive	

phony += $(RECURSIVE_TARGETS)
$(RECURSIVE_TARGETS):
	target=`echo $@ | sed 's/-recursive//'` ;\
	for dir in $(SUBDIRS) ; do \
		( cd $$dir && $(MAKE) $$target \
			DISTDIR="$(PWD)/$(basename $(DISTDIR))" \
			DESTDIR="$(PWD)/$(basename $(DESTDIR))" \
		) || exit 2 ;\
	done

phony += clean
clean:
	if [ -n "$(DISTPKG)" ]; then\
		$(RM) $(DISTPKG);\
	fi
	if [ -n "$(DISTDIR)" ]; then\
		$(RM) -r $(DISTDIR);\
	fi
	
phony += dist
dist: 	$(DISTPKG)
	
$(TARBZ2): distdir
	echo "Making $@"
	$(CP) $(DISTFILES) $(DISTDIR)
	$(TAR) -cjf $@ $(DISTDIR)
	$(RM) -r $(DISTDIR)

phony += distdir
distdir: distdir-recursive
	if [ -z "$(DISTDIR)" ]; then \
		echo "no DISTDIR in $(SUBDIR)" ;\
		exit 2 ;\
	fi
	for i in $(DISTFILES); do\
		if [ -n "$(SUBDIR)" ]; then\
			destdir=$(DISTDIR)/$(SUBDIR)/`dirname $$i`;\
		else \
			destdir=$(DISTDIR);\
		fi;\
		$(MKDIR) -p "$$destdir" &&\
		$(CP) "$$i" "$$destdir";\
	done

phony += pre-install-hook post-install-hook

phony += install
install: install-recursive
	if [ -n "$(APP_DIST)" ]; then\
		echo "Installing app files";\
		$(MKDIR) -p $(DESTDIR)/$(appdir);\
		$(CP) $(APP_DIST) $(DESTDIR)/$(appdir);\
	fi
	echo "TODO: *_DIST, set permissions, set ownerships"

.PHONY: $(phony)
