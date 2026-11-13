apk:
	flutter build apk

web:
	flutter build web
.PHONY: apk web dev-web dark light auto-theme

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

dev-web:
	flutter run -d web-server --web-port=3000 --dart-define-from-file=env.json
