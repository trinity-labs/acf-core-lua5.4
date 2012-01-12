include ../config.mk

BIN_DIST=acf-cli acfpasswd

EXTRA_DIST=Makefile
DISTFILES=$(BIN_DIST) $(EXTRA_DIST)

install_dir=$(DESTDIR)/$(bindir)
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
	for i in $(BIN_DIST); do\
		dest=`dirname "$(install_dir)/$$i"`;\
		install -Dm755 "$$i" "$$dest"/$$i ;\
	done
	chmod 700 $(install_dir)/acf-cli

.PHONY: $(phony)
