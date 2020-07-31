SHELL = /bin/bash
TOOL_NAME = nef

prefix ?= /usr/local
version ?= 0.6.2

BUILD_PATH = /tmp/$(TOOL_NAME)/$(version)
PREFIX_BIN = $(prefix)/bin
PREFIX_TESTS = $(prefix)/share/tests
TAR_FILENAME = $(version).tar.gz
SWIFT_PACKAGE_PATH = .
BINARIES_PATH = $(BUILD_PATH)/release
BINARIES =  nefc\
						nef-clean\
						nef-playground\
						nef-markdown\
						nef-markdown-page\
						nef-jekyll\
						nef-jekyll-page\
						nef-carbon\
						nef-carbon-page\
						nef-playground-book


.PHONY: install
install: uninstall build install_folders bash
	$(foreach binary,$(BINARIES),$(shell install $(BINARIES_PATH)/$(binary) $(PREFIX_BIN)/$(binary)))
	@install $(BINARIES_PATH)/nef-menu $(PREFIX_BIN)/nef
	@cp -R Documentation.app $(PREFIX_TESTS)

.PHONY: install_folders
install_folders:
	@install -d "$(PREFIX_BIN)"
	@install -d "$(PREFIX_TESTS)"

.PHONY: build
build: clean
	@swift build --disable-sandbox --package-path $(SWIFT_PACKAGE_PATH) --configuration release --build-path $(BUILD_PATH)

.PHONY: uninstall
uninstall:
	@rm -f $(PREFIX_BIN)/$(TOOL_NAME)*
	@rm -rf $(PREFIX_TESTS)

.PHONY: clean
clean:
	@rm -rf $(BUILD_PATH)

.PHONY: zip
zip: build
	@zip $(TOOL_NAME).$(version).zip $(foreach binary,$(BINARIES),$(BINARIES_PATH)/$(binary))

.PHONY: bash
bash:
	@mkdir -p ~/.bash_completions
	@nef --generate-completion-script bash > ~/.bash_completions/nef.bash
	$(shell if [[ ! -f ~/.bashrc ]] || [[ ! `grep "nef.bash" ~/.bashrc` ]]; then echo "source ~/.bash_completions/nef.bash" >> ~/.bashrc; fi)
