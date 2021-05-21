CP = cp --recursive --force

INSTALL_BIN   = $(DESTDIR)$(PREFIX)/bin
INSTALL_SHARE = $(DESTDIR)$(PREFIX)/share/docgen
INSTALL_DOC   = $(DESTDIR)$(PREFIX)/share/doc/docgen

.PHONY: install test

install:
	mkdir --parents $(INSTALL_BIN) $(INSTALL_SHARE) $(INSTALL_DOC)
	$(CP) md2html $(INSTALL_BIN)
	$(CP) resources \
		Doxyfile.in \
		DocGenConfig.cmake \
		DocGen-functions.cmake \
		$(INSTALL_SHARE)
	$(CP) resources $(INSTALL_DOC)
	[ `which showdown` ] && ./md2html README.md $(INSTALL_DOC) ; exit 0

test:
	./test/md2htmlTest
