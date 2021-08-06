#*****************************************************************************
# DESCRIPTION: Verilator top level: Makefile pre-configure version
#
# This file is part of Verilator.
#
# Code available from: https://verilator.org
#
#*****************************************************************************
#
# Copyright 2003-2021 by Wilson Snyder. This program is free software; you
# can redistribute it and/or modify it under the terms of either the GNU
# Lesser General Public License Version 3 or the Perl Artistic License
# Version 2.0.
# SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0
#
#****************************************************************************/
#
# make all	to compile and build Verilator.
# make install	to install it.
# make TAGS	to update tags tables.
#
# make clean  or  make mostlyclean
#      Delete all files from the current directory that are normally
#      created by building the program.	 Don't delete the files that
#      record the configuration.  Also preserve files that could be made
#      by building, but normally aren't because the distribution comes
#      with them.
#
# make distclean
#      Delete all files from the current directory that are created by
#      configuring or building the program.  If you have unpacked the
#      source and built the program without creating any other files,
#      `make distclean' should leave only the files that were in the
#      distribution.
#
# make maintainer-clean
#      Delete everything from the current directory that can be
#      reconstructed with this Makefile.  This typically includes
#      everything deleted by distclean, plus more: C source files
#      produced by Bison, tags tables, info files, and so on.

#### Start of system configuration section. ####

srcdir = .

HOST = @HOST@
EXEEXT = 

DOXYGEN = doxygen
INSTALL = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644
MAKEINFO = makeinfo
POD2TEXT = pod2text
MKINSTALLDIRS = $(SHELL) $(srcdir)/src/mkinstalldirs
PERL = /usr/bin/perl

# Version (for docs/guide/conf.py)
PACKAGE_VERSION_NUMBER = 4.211

# Destination prefix for RPMs
DESTDIR =

#### Don't edit: You're much better using configure switches to set these
prefix = /usr/local
exec_prefix = ${prefix}

# Directory in which to install scripts.
bindir = ${exec_prefix}/bin

# Directory in which to install manpages.
mandir = ${datarootdir}/man

# Directory in which to install library files.
datadir = ${datarootdir}

# Directory in which to install documentation info files.
infodir = ${datarootdir}/info

# Directory in which to install package specific files
# Generally ${prefix}/share/verilator
pkgdatadir = ${datarootdir}/verilator

# Directory in which to install pkgconfig file
# Generally ${prefix}/share/pkgconfig
pkgconfigdir = ${datarootdir}/pkgconfig

# Directory in which to install data across multiple architectures
datarootdir = ${prefix}/share

# Compile options
CFG_WITH_CCWARN = no
CFG_WITH_DEFENV = yes
CFG_WITH_LONGTESTS = no
PACKAGE_VERSION = 4.211 devel

#### End of system configuration section. ####
######################################################################

.SUFFIXES:

SHELL = /bin/sh

SUBDIRS = docs src test_regress \
	examples/cmake_hello_c \
	examples/cmake_hello_sc \
	examples/cmake_tracing_c \
	examples/cmake_tracing_sc \
	examples/cmake_protect_lib \
	examples/make_hello_c \
	examples/make_hello_sc \
	examples/make_tracing_c \
	examples/make_tracing_sc \
	examples/make_protect_lib \
	examples/xml_py \

INFOS = verilator.html verilator.pdf

INFOS_OLD = README README.html README.pdf

INST_PROJ_FILES = \
	bin/verilator \
	bin/verilator_ccache_report \
	bin/verilator_coverage \
	bin/verilator_gantt \
	bin/verilator_includer \
	bin/verilator_profcfunc \
	include/verilated.mk \
	include/*.[chv]* \
	include/gtkwave/*.[chv]* \
	include/vltstd/*.[chv]* \

INST_PROJ_BIN_FILES = \
	bin/verilator_bin$(EXEEXT) \
	bin/verilator_bin_dbg$(EXEEXT) \
	bin/verilator_coverage_bin_dbg$(EXEEXT) \

EXAMPLES_FIRST = \
	examples/make_hello_c \
	examples/make_hello_sc \

EXAMPLES = $(EXAMPLES_FIRST) $(filter-out $(EXAMPLES_FIRST), $(sort $(wildcard examples/*)))

# See uninstall also - don't put wildcards in this variable, it might uninstall other stuff
VL_INST_MAN_FILES = verilator.1 verilator_coverage.1 verilator_gantt.1 verilator_profcfunc.1

default: all
all: all_nomsg msg_test
all_nomsg: verilator_exe $(VL_INST_MAN_FILES)

.PHONY:verilator_exe
.PHONY:verilator_bin$(EXEEXT)
.PHONY:verilator_bin_dbg$(EXEEXT)
.PHONY:verilator_coverage_bin_dbg$(EXEEXT)
verilator_exe verilator_bin$(EXEEXT) verilator_bin_dbg$(EXEEXT) verilator_coverage_bin_dbg$(EXEEXT):
	@echo ------------------------------------------------------------
	@echo "making verilator in src"
	$(MAKE) -C src $(OBJCACHE_JOBS)

.PHONY:msg_test
msg_test: all_nomsg
	@echo "Build complete!"
	@echo
	@echo "Now type 'make test' to test."
	@echo

.PHONY: test
ifeq ($(CFG_WITH_LONGTESTS),yes)	# Local... Else don't burden users
test: smoke-test test_regress
# examples is part of test_regress's test_regress/t/t_a2_examples.pl
# (because that allows it to run in parallel with other test_regress's)
else
test: smoke-test examples
endif
	@echo "Tests passed!"
	@echo
	@echo "Now type 'make install' to install."
	@echo "Or type 'make' inside an examples subdirectory."
	@echo

smoke-test: all_nomsg
	test_regress/t/t_a1_first_cc.pl
	test_regress/t/t_a2_first_sc.pl

test_regress: all_nomsg
	$(MAKE) -C test_regress

examples: all_nomsg
	for p in $(EXAMPLES) ; do \
	  $(MAKE) -C $$p VERILATOR_ROOT=`pwd` || exit 10; \
	done

.PHONY: docs
docs: info

info: $(INFOS)

%.1: ${srcdir}/bin/%
	pod2man $< $@

.PHONY: verilator.html
verilator.html:
	$(MAKE) -C docs html

# PDF needs DIST variables; but having configure.ac as dependency isn't detected
.PHONY: verilator.pdf
verilator.pdf: Makefile
	$(MAKE) -C docs verilator.pdf

# See uninstall also - don't put wildcards in this variable, it might uninstall other stuff
VL_INST_BIN_FILES = verilator verilator_bin$(EXEEXT) verilator_bin_dbg$(EXEEXT) verilator_coverage_bin_dbg$(EXEEXT) \
	verilator_ccache_report verilator_coverage verilator_gantt verilator_includer verilator_profcfunc
# Some scripts go into both the search path and pkgdatadir,
# so they can be found by the user, and under $VERILATOR_ROOT.

VL_INST_INC_BLDDIR_FILES = \
	include/verilated_config.h \
	include/verilated.mk \

# Files under srcdir, instead of build time
VL_INST_INC_SRCDIR_FILES = \
	include/*.[chv]* \
	include/gtkwave/*.[chv]* \
	include/vltstd/*.[chv]* \

VL_INST_DATA_SRCDIR_FILES = \
	examples/*/*.[chv]*  examples/*/Makefile* \
	examples/*/CMakeLists.txt

installbin:
	$(MKINSTALLDIRS) $(DESTDIR)$(bindir)
	( cd ${srcdir}/bin ; $(INSTALL_PROGRAM) verilator $(DESTDIR)$(bindir)/verilator )
	( cd ${srcdir}/bin ; $(INSTALL_PROGRAM) verilator_coverage $(DESTDIR)$(bindir)/verilator_coverage )
	( cd ${srcdir}/bin ; $(INSTALL_PROGRAM) verilator_gantt $(DESTDIR)$(bindir)/verilator_gantt )
	( cd ${srcdir}/bin ; $(INSTALL_PROGRAM) verilator_profcfunc $(DESTDIR)$(bindir)/verilator_profcfunc )
	( cd bin ; $(INSTALL_PROGRAM) verilator_bin$(EXEEXT) $(DESTDIR)$(bindir)/verilator_bin$(EXEEXT) )
	( cd bin ; $(INSTALL_PROGRAM) verilator_bin_dbg$(EXEEXT) $(DESTDIR)$(bindir)/verilator_bin_dbg$(EXEEXT) )
	( cd bin ; $(INSTALL_PROGRAM) verilator_coverage_bin_dbg$(EXEEXT) $(DESTDIR)$(bindir)/verilator_coverage_bin_dbg$(EXEEXT) )
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/bin
	( cd ${srcdir}/bin ; $(INSTALL_PROGRAM) verilator_includer $(DESTDIR)$(pkgdatadir)/bin/verilator_includer )
	( cd ${srcdir}/bin ; $(INSTALL_PROGRAM) verilator_ccache_report $(DESTDIR)$(pkgdatadir)/bin/verilator_ccache_report )

# Man files can either be part of the original kit, or built in current directory
# So important we use $^ so VPATH is searched
installman: $(VL_INST_MAN_FILES)
	$(MKINSTALLDIRS) $(DESTDIR)$(mandir)/man1
	for p in $^ ; do \
	  $(INSTALL_DATA) $$p $(DESTDIR)$(mandir)/man1/$$p; \
	done

installdata:
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/include/gtkwave
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/include/vltstd
	for p in $(VL_INST_INC_BLDDIR_FILES) ; do \
	  $(INSTALL_DATA) $$p $(DESTDIR)$(pkgdatadir)/$$p; \
	done
	cd $(srcdir) \
	; for p in $(VL_INST_INC_SRCDIR_FILES) ; do \
	  $(INSTALL_DATA) $$p $(DESTDIR)$(pkgdatadir)/$$p; \
	done
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/examples/make_hello_c
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/examples/make_hello_sc
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/examples/make_tracing_c
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/examples/make_tracing_sc
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/examples/make_protect_lib
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/examples/cmake_hello_c
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/examples/cmake_hello_sc
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/examples/cmake_tracing_c
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/examples/cmake_tracing_sc
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/examples/cmake_protect_lib
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgdatadir)/examples/xml_py
	cd $(srcdir) \
	; for p in $(VL_INST_DATA_SRCDIR_FILES) ; do \
	  $(INSTALL_DATA) $$p $(DESTDIR)$(pkgdatadir)/$$p; \
	done
	$(MKINSTALLDIRS) $(DESTDIR)$(pkgconfigdir)
	$(INSTALL_DATA) verilator.pc $(DESTDIR)$(pkgconfigdir)
	$(INSTALL_DATA) verilator-config.cmake $(DESTDIR)$(pkgdatadir)
	$(INSTALL_DATA) verilator-config-version.cmake $(DESTDIR)$(pkgdatadir)

# We don't trust rm -rf, so rmdir instead as it will fail if user put in other files
uninstall:
	-cd $(DESTDIR)$(bindir) && rm -f $(VL_INST_BIN_FILES)
	-cd $(DESTDIR)$(pkgdatadir)/bin && rm -f $(VL_INST_BIN_FILES)
	-cd $(DESTDIR)$(mandir)/man1 && rm -f $(VL_INST_MAN_FILES)
	-cd $(DESTDIR)$(pkgdatadir) && rm -f $(VL_INST_INC_BLDDIR_FILES)
	-cd $(DESTDIR)$(pkgdatadir) && rm -f $(VL_INST_INC_SRCDIR_FILES)
	-cd $(DESTDIR)$(pkgdatadir) && rm -f $(VL_INST_DATA_SRCDIR_FILES)
	-rm $(DESTDIR)$(pkgconfigdir)/verilator.pc
	-rm $(DESTDIR)$(pkgdatadir)/verilator-config.cmake
	-rm $(DESTDIR)$(pkgdatadir)/verilator-config-version.cmake
	-rmdir $(DESTDIR)$(pkgdatadir)/bin
	-rmdir $(DESTDIR)$(pkgdatadir)/include/gtkwave
	-rmdir $(DESTDIR)$(pkgdatadir)/include/vltstd
	-rmdir $(DESTDIR)$(pkgdatadir)/include
	-rmdir $(DESTDIR)$(pkgdatadir)/examples/make_hello_c
	-rmdir $(DESTDIR)$(pkgdatadir)/examples/make_hello_sc
	-rmdir $(DESTDIR)$(pkgdatadir)/examples/make_tracing_c
	-rmdir $(DESTDIR)$(pkgdatadir)/examples/make_tracing_sc
	-rmdir $(DESTDIR)$(pkgdatadir)/examples/make_protect_lib
	-rmdir $(DESTDIR)$(pkgdatadir)/examples/cmake_hello_c
	-rmdir $(DESTDIR)$(pkgdatadir)/examples/cmake_hello_sc
	-rmdir $(DESTDIR)$(pkgdatadir)/examples/cmake_tracing_c
	-rmdir $(DESTDIR)$(pkgdatadir)/examples/cmake_tracing_sc
	-rmdir $(DESTDIR)$(pkgdatadir)/examples/cmake_protect_lib
	-rmdir $(DESTDIR)$(pkgdatadir)/examples/xml_py
	-rmdir $(DESTDIR)$(pkgdatadir)/examples
	-rmdir $(DESTDIR)$(pkgdatadir)
	-rmdir $(DESTDIR)$(pkgconfigdir)

install: all_nomsg install-all
install-all: installbin installman installdata install-msg

install-here: installman info

# Use --xml flag to see the cppcheck code to use for suppression
CPPCHECK_CPP = $(wildcard \
	$(srcdir)/examples/*/*.cpp \
	$(srcdir)/include/*.cpp \
	$(srcdir)/src/*.cpp )
CPPCHECK_H = $(wildcard \
	$(srcdir)/include/*.h \
	$(srcdir)/src/*.h )
CPPCHECK_YL = $(wildcard \
	$(srcdir)/src/*.y \
	$(srcdir)/src/*.l )
CPPCHECK = src/cppcheck_filtered cppcheck
CPPCHECK_FLAGS = --enable=all --inline-suppr \
	--suppress=unusedScopedObject --suppress=cstyleCast --suppress=useInitializationList \
	--suppress=nullPointerRedundantCheck
CPPCHECK_FLAGS += --xml
CPPCHECK_DEP = $(subst .cpp,.cppcheck,$(CPPCHECK_CPP))
CPPCHECK_INC = -I$(srcdir)/include -I$(srcdir)/src/obj_dbg -I$(srcdir)/src

cppcheck: $(CPPCHECK_DEP)
%.cppcheck: %.cpp
	$(CPPCHECK) $(CPPCHECK_FLAGS) -DVL_DEBUG=1 -DVL_CPPCHECK=1 -DVL_THREADED=1 $(CPPCHECK_INC) $<

CLANGTIDY = clang-tidy
CLANGTIDY_FLAGS = -config='' -checks='-fuchsia-*,-cppcoreguidelines-avoid-c-arrays,-cppcoreguidelines-init-variables'
CLANGTIDY_DEP = $(subst .h,.h.tidy,$(CPPCHECK_H)) \
	$(subst .cpp,.cpp.tidy,$(CPPCHECK_CPP))
CLANGTIDY_DEFS = -DVL_DEBUG=1 -DVL_THREADED=1 -DVL_CPPCHECK=1

clang-tidy: $(CLANGTIDY_DEP)
%.cpp.tidy: %.cpp
	$(CLANGTIDY) $(CLANGTIDY_FLAGS) $< -- $(CLANGTIDY_DEFS) $(CPPCHECK_INC) | 2>&1 tee $@
%.h.tidy: %.h
	$(CLANGTIDY) $(CLANGTIDY_FLAGS) $< -- $(CLANGTIDY_DEFS) $(CPPCHECK_INC) | 2>&1 tee $@

analyzer-src:
	-rm -rf src/obj_dbg
	scan-build $(MAKE) -k verilator_coverage_bin_dbg$(EXEEXT) verilator_bin_dbg$(EXEEXT)

analyzer-include:
	-rm -rf examples/*/obj*
	scan-build $(MAKE) -k examples

format: clang-format yapf format-pl-exec

CLANGFORMAT = clang-format-11
CLANGFORMAT_FLAGS = -i
CLANGFORMAT_FILES = $(CPPCHECK_CPP) $(CPPCHECK_H) $(CPPCHECK_YL) test_regress/t/*.c* test_regress/t/*.h

clang-format:
	@$(CLANGFORMAT) --version | egrep 11.0 > /dev/null \
		|| echo "*** You are not using clang-format 11.0, indents may differ from master's ***"
	$(CLANGFORMAT) $(CLANGFORMAT_FLAGS) $(CLANGFORMAT_FILES)

PY_PROGRAMS = \
	bin/verilator_ccache_report \
	examples/xml_py/vl_file_copy \
	examples/xml_py/vl_hier_graph \
	docs/guide/conf.py \
	docs/bin/vl_sphinx_extract \
	docs/bin/vl_sphinx_fix \
	src/astgen \
	src/bisonpre \
	src/config_rev \
	src/cppcheck_filtered \
	src/flexfix \
	src/vlcovgen \
	test_regress/t/*.pf \
	nodist/code_coverage \
	nodist/dot_importer \
	nodist/fuzzer/actual_fail \
	nodist/fuzzer/generate_dictionary \
	nodist/install_test \

PY_FILES = \
	$(PY_PROGRAMS) \
	nodist/code_coverage.dat \

YAPF = yapf3
YAPF_FLAGS = -i

yapf:
	$(YAPF) $(YAPF_FLAGS) $(PY_FILES)

FLAKE8 = flake8
FLAKE8_FLAGS = \
	--extend-exclude=fastcov.py \
	--ignore=E123,E129,E251,E501,W503,W504,E701

PYLINT = pylint
PYLINT_FLAGS = --disable=R0801

lint-py:
	-$(FLAKE8) $(FLAKE8_FLAGS) $(PY_PROGRAMS)
	-$(PYLINT) $(PYLINT_FLAGS) $(PY_PROGRAMS)

format-pl-exec:
	-chmod a+x test_regress/t/*.pl

install-msg:
	@echo
	@echo "Installed binaries to $(DESTDIR)$(bindir)/verilator"
	@echo "Installed man to $(DESTDIR)$(mandir)/man1"
	@echo "Installed examples to $(DESTDIR)$(pkgdatadir)/examples"
	@echo
	@echo "For documentation see 'man verilator' or 'verilator --help'"
	@echo "For forums and to report bugs see https://verilator.org"
	@echo

IN_WILD := ${srcdir}/*.in ${srcdir}/*/*.in

# autoheader might not change config_build.h.in, so touch it
${srcdir}/config_build.h: ${srcdir}/config_build.h.in configure
	cd ${srcdir} && autoheader
	touch $@
Makefile: Makefile.in config.status $(IN_WILD)
	./config.status
src/Makefile: src/Makefile.in Makefile
config.status: configure
	./config.status --recheck

configure: configure.ac
ifeq ($(CFG_WITH_CCWARN),yes)	# Local... Else don't burden users
	autoconf --warnings=all
else
	autoconf
endif

maintainer-clean::
	@echo "This command is intended for maintainers to use;"
	@echo "rebuilding the deleted files requires autoconf."
	rm -f configure

clean mostlyclean distclean maintainer-clean maintainer-copy::
	for dir in $(SUBDIRS); do \
	  echo making $@ in $$dir ; \
	  $(MAKE) -C $$dir $@ ; \
	done

clean mostlyclean distclean maintainer-clean::
	rm -f $(SCRIPTS) *.tmp
	rm -f *.aux *.cp *.cps *.dvi *.fn *.fns *.ky *.kys *.log
	rm -f *.pg *.pgs *.toc *.tp *.tps *.vr *.vrs *.idx
	rm -f *.ev *.evs *.ov *.ovs *.cv *.cvs *.ma *.mas
	rm -f *.tex
	rm -rf examples/*/obj_dir* examples/*/logs
	rm -rf test_*/obj_dir
	rm -rf nodist/fuzzer/dictionary
	rm -rf nodist/obj_dir
	rm -rf verilator.txt

distclean maintainer-clean::
	rm -f *.info* *.1 $(INFOS) $(INFOS_OLD) $(VL_INST_MAN_FILES)
	rm -f Makefile config.status config.cache config.log TAGS
	rm -f verilator_bin* verilator_coverage_bin*
	rm -f bin/verilator_bin* bin/verilator_coverage_bin*
	rm -f include/verilated.mk include/verilated_config.h

TAGFILES=${srcdir}/*/*.cpp ${srcdir}/*/*.h ${srcdir}/*/*.in \
	${srcdir}/*.in ${srcdir}/*.pod

TAGS:	$(TAGFILES)
	etags $(TAGFILES)

.PHONY: doxygen

doxygen:
	$(MAKE) -C docs doxygen

######################################################################
# Distributions

DISTTITLE := Verilator $(word 1,$(PACKAGE_VERSION))
DISTNAME := verilator-$(word 1,$(PACKAGE_VERSION))
DISTDATEPRE := $(word 2,$(PACKAGE_VERSION))
DISTDATE := $(subst /,-,$(DISTDATEPRE))
DISTTAGNAME := $(subst .,_,$(subst -,_,$(DISTNAME)))

tag:
	svnorcvs tag $(DISTTAGNAME)

maintainer-diff:
	svnorcvs diff $(DISTTAGNAME)

preexist:
	svnorcvs nexists $(DISTTAGNAME)

maintainer-dist: preexist tag
	svnorcvs release $(DISTTAGNAME)