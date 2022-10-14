
PHONY: bundle apks build_runner intl install release bump patch_bump minor_bump major_bump patch_release minor_release major_release

install:
	flutter install

bundle:
	flutter build appbundle --no-shrink

apks:
	flutter build apk --split-per-abi --no-tree-shake-icons --no-shrink --no-sound-null-safety

build_runner:
	flutter pub run build_runner build --delete-conflicting-outputs

intl:
	flutter gen-l10n

bump:
	cider bump build

patch_bump:
	cider bump patch

minor_bump:
	cider bump minor

major_bump:
	cider bump major

release: bump bundle

patch_release: patch_bump bundle

minor_release: minor_bump bundle

major_release: major_bump bundle