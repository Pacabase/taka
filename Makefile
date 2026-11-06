.PHONY: help test licences

default: help

help:
	@echo "make test     - Run every unit test"
	@echo "make licences - Regenerate the background helper's licences for About"

test:
	fvm flutter test --tags unit
	cd packages/core && fvm dart test --tags unit
	cd packages/agent && fvm dart test --tags unit

licences:
	fvm flutter pub get --enforce-lockfile
	fvm dart pub get --enforce-lockfile -C packages/agent
	fvm dart run tool/agent_licences.dart
