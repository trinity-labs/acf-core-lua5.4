PACKAGE=acf-core
VERSION=2.0

#SUBDIRS=app cgi-bin lib static www
SUBDIRS=app
EXTRA_DIST=README.makefiles

# since this is top level dir we have to set SUBDIR to blank
SUBDIR=

include config.mk
include acf.mk
