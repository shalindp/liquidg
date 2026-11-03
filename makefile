apk:
	flutter build apk
.PHONY: apk dark light auto-theme

dark:
	adb shell "cmd uimode night yes"

light:
	adb shell "cmd uimode night no"

auto-theme:
	adb shell "cmd uimode night auto"

emulator:
	emulator -avd flutter_pixel9

dev:
	@./tool/dev.sh