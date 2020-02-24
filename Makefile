TOOL_NAME = nef
VERSION = 0.6.0

PREFIX_BIN = /usr/local/bin
BUILD_PATH = bin/nef
TAR_FILENAME = $(VERSION).tar.gz
SWIFT_PACKAGE_PATH = project
BINARIES_PATH = $(BUILD_PATH)/release
BINARIES =  nef\
						nefc\
						nef-clean\
						nef-playground\
						nef-markdown\
						nef-markdown-page\
						nef-jekyll\
						nef-jekyll-page\
						nef-carbon\
						nef-carbon-page\
						nef-playground-book


.PHONY: build

install: build
	install -d "$(PREFIX_BIN)"
	$(foreach binary,$(BINARIES),$(shell install -C -m 755 $(BINARIES_PATH)/$(binary) $(PREFIX_BIN)/$(binary)))

build:
	swift build --disable-sandbox --package-path $(SWIFT_PACKAGE_PATH) --configuration release --build-path $(BUILD_PATH)

uninstall:
	rm -f $(PREFIX_BIN)/$(TOOL_NAME)*

zip: build
	zip $(TOOL_NAME).$(VERSION).zip $(foreach binary,$(BINARIES),$(BINARIES_PATH)/$(binary))

get_sha:
	curl -OLs https://github.com/bow-swift/$(TOOL_NAME)/archive/$(TAR_FILENAME)
	shasum -a 256 $(TAR_FILENAME) | cut -f 1 -d " " > sha_$(VERSION).txt
	rm $(TAR_FILENAME)

brew_push: get_sha
	SHA=$(shell cat sha_$(VERSION).txt); \
	brew bump-formula-pr --url=https://github.com/bow-swift/$(TOOL_NAME)/archive/$(TAR_FILENAME) --sha256=$$SHA
