
export THEOS_DEVICE_IP=192.168.1.7
ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = ClearOnOpen
ClearOnOpen_FILES = Tweak.xm
ClearOnOpen_FRAMEWORKS = UIKit

THEOS_BUILD_DIR = debs

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
