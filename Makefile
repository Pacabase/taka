.PHONY: help agent macos run test

ARCH := $(if $(filter arm64,$(shell uname -m)),arm64,x64)
AGENT := packages/agent/build/cli/macos_$(ARCH)/bundle
APP := build/macos/Build/Products/Release/Taka.app
AGENT_APP := $(APP)/Contents/Library/LoginItems/TakaAgent.app

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
	rm -rf $(AGENT_APP)
	mkdir -p $(AGENT_APP)/Contents/MacOS $(AGENT_APP)/Contents/Resources
	cp packages/agent/macos/Info.plist $(AGENT_APP)/Contents/
	cp $(AGENT)/bin/taka_agent $(AGENT_APP)/Contents/MacOS/Taka
	cp -R $(AGENT)/lib $(AGENT_APP)/Contents/lib
	cp $(AGENT)/*.png $(APP)/Contents/Resources/AppIcon.icns $(AGENT_APP)/Contents/Resources/
	codesign --force --deep --sign - $(APP)

run: agent
	TAKA_AGENT=$(CURDIR)/$(AGENT)/bin/taka_agent fvm flutter run -d macos

test:
	fvm flutter test --tags unit
	cd packages/core && fvm dart test --tags unit
	cd packages/agent && fvm dart test --tags unit
