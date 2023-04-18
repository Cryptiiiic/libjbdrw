build_release: | clean pack_release
build_debug: | clean pack_debug
.PHONY: build_release

VERSION=0
RELEASE_CFLAGS = -DNDEBUG -Os -std=gnu11 -flto=thin
DEBUG_CFLAGS = -DNDEBUG -g -O0 -std=gnu11
CC = xcrun clang -arch arm64 -target arm64-apple-darwin -miphoneos-version-min=11.0 -arch arm64e -target arm64e-apple-darwin -miphoneos-version-min=12.0 -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path) -Wl,-export_dynamic -shared -Iinclude -Isrc -Llib -ljailbreak -framework Foundation

release:
	$(CC) $(RELEASE_CFLAGS) $(wildcard src/*.m) -DVERSION=$(VERSION) -o libjbdrw.$(VERSION).dylib
	ldid -S libjbdrw.$(VERSION).dylib
debug:
	$(CC) $(DEBUG_CFLAGS) $(wildcard src/*.m) -DVERSION=$(VERSION) -o libjbdrw.$(VERSION).dylib
	ldid -S libjbdrw.$(VERSION).dylib

pack:
	rm -rf .tmp || true
	mkdir .tmp
	cd .tmp && \
	mkdir -p com.cryptiiiic.libjbdrw/DEBIAN && \
	mkdir -p com.cryptiiiic.libjbdrw/var/jb/usr/lib/libkrw/ && \
	pwd && \
	touch com.cryptiiiic.libjbdrw/DEBIAN/control && \
	cp ../libjbdrw.$(VERSION).dylib com.cryptiiiic.libjbdrw/var/jb/usr/lib/libkrw/ && \
	( echo 'Package: com.cryptiiiic.libjbdrw'; \
	  echo 'Name: libjbdrw'; \
	  echo 'Author: Cryptiiiic'; \
	  echo 'Maintainer: Cryptiiiic'; \
	  echo 'Architecture: iphoneos-arm64'; \
	  echo 'Version: $(VERSION)'; \
	  echo 'Priority: optional'; \
	  echo 'Section: Development'; \
	  echo 'Description: Plugin for libkrw interacing with fugu15 jailbreakd'; \
	  echo 'Homepage: https://github.com/Cryptiiiic/libjbdrw'; \
	) > com.cryptiiiic.libjbdrw/DEBIAN/control && \
	dpkg-deb -Zzstd -b com.cryptiiiic.libjbdrw ../com.cryptiiiic.libjbdrw_$(VERSION)_iphoneos-arm64.deb && \
	rm -rf .tmp || true

pack_release: release
	$(MAKE) pack

pack_debug: debug
	$(MAKE) pack

clean:
	rm -rf $(wildcard libjbdrw.*.dylib)
