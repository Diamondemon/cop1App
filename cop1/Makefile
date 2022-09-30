
PHONY: bundle apks build intl install release bump

install:
	flutter install

bundle:
	flutter build appbundle --no-shrink

apks:
	flutter build apk --split-per-abi --no-tree-shake-icons --no-shrink --no-sound-null-safety

build:
	flutter pub run build_runner build --delete-conflicting-outputs

intl:
	flutter pub gen-l10n

bump:
	cider bump build

release: bump bundle