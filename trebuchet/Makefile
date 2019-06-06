include theos/makefiles/common.mk
export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2222
export ARCHS = armv7 armv7s arm64
export TARGET = iphone:clang:7.1

TWEAK_NAME = Trebuchet
Trebuchet_FILES = Tweak.xm
Trebuchet_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
