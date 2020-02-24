TOOL_NAME = nef
VERSION = 0.6.0

PREFIX = /usr/local
INSTALL_PATH = $(PREFIX)/bin/$(TOOL_NAME)
BUILD_PATH = bin/release/$(TOOL_NAME)
TAR_FILENAME = $(VERSION).tar.gz

.PHONY: build docs

install: build
	install -d "$(PREFIX)/bin"
	install -C -m 755 $(BUILD_PATH)/nef $(INSTALL_PATH)
	install -C -m 755 $(BUILD_PATH)/nefc $(INSTALL_PATH)
	install -C -m 755 $(BUILD_PATH)/nef-clean $(INSTALL_PATH)
	install -C -m 755 $(BUILD_PATH)/nef-playground $(INSTALL_PATH)
	install -C -m 755 $(BUILD_PATH)/nef-markdown $(INSTALL_PATH)
	install -C -m 755 $(BUILD_PATH)/nef-markdown-page $(INSTALL_PATH)
	install -C -m 755 $(BUILD_PATH)/nef-jekyll $(INSTALL_PATH)
	install -C -m 755 $(BUILD_PATH)/nef-jekyll-page $(INSTALL_PATH)
	install -C -m 755 $(BUILD_PATH)/nef-carbon $(INSTALL_PATH)
	install -C -m 755 $(BUILD_PATH)/nef-carbon-page $(INSTALL_PATH)
	install -C -m 755 $(BUILD_PATH)/nef-playground-book $(INSTALL_PATH)

build:
	swift build --disable-sandbox --package-path project --configuration release --build-path $(BUILD_PATH)

uninstall:
	rm -f $(INSTALL_PATH)

zip: build
	zip -D $(TOOL_NAME).macos.zip $(BUILD_PATH)

version: build
	echo "$(shell $(BUILD_PATH)/nef version)"

get_sha:
	curl -OLs https://github.com/bow-swift/$(TOOL_NAME)/archive/$(VERSION).tar.gz
	SHA=$(shell shasum -a 256 $(TAR_FILENAME) | cut -f 1 -d " ")
	rm $(TAR_FILENAME)
	echo $SHA

brew_push:
	SHA=$(shell make get_sha)
	echo "brew bump-formula-pr --url=https://github.com/eneko/$(TOOL_NAME)/archive/$(VERSION).tar.gz --sha256=$SHA"
