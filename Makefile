.PHONY: help agent macos run test

ARCH := $(if $(filter arm64,$(shell uname -m)),arm64,x64)
AGENT := packages/agent/build/cli/macos_$(ARCH)/bundle
APP := build/macos/Build/Products/Release/Taka.app

default: help

help:
	@echo "make macos   - Build Taka.app with its agent inside"
	@echo "make run     - Run the app from source, with a freshly built agent"
	@echo "make test    - Run every unit test"

agent:
	cd packages/agent && fvm dart build cli
	cp packages/agent/assets/*.png $(AGENT)/

macos: agent
	fvm flutter build macos --release
	rm -rf $(APP)/Contents/Helpers/agent
	mkdir -p $(APP)/Contents/Helpers
	cp -R $(AGENT) $(APP)/Contents/Helpers/agent
	codesign --force --deep --sign - $(APP)

run: agent
	TAKA_AGENT=$(CURDIR)/$(AGENT)/bin/taka_agent fvm flutter run -d macos

test:
	fvm flutter test --tags unit
	cd packages/core && fvm dart test --tags unit
	cd packages/agent && fvm dart test --tags unit
