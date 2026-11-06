.PHONY: help agent macos run test licences

ARCH := $(if $(filter arm64,$(shell uname -m)),arm64,x64)
AGENT := packages/agent/build/cli/macos_$(ARCH)/bundle
APP := build/macos/Build/Products/Release/Taka.app
LOGIN_ITEMS := $(APP)/Contents/Library/LoginItems
AGENT_APP := $(LOGIN_ITEMS)/Taka.app

default: help

help:
	@echo "make macos    - Build Taka.app with its agent inside"
	@echo "make run      - Run the app from source, with a freshly built agent"
	@echo "make test     - Run every unit test"
	@echo "make licences - List the background helper's package licences for About"

agent:
	cd packages/agent && fvm dart build cli
	cp packages/agent/assets/*.png $(AGENT)/

macos: agent
	fvm flutter build macos --release
	rm -rf $(LOGIN_ITEMS)
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

licences:
	fvm dart run tool/agent_licences.dart
