export TARGET=iphone:clang
export THEOS_DEVICE_IP=192.168.1.88

ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = OpenOnSearch
OpenOnSearch_FILES = Tweak.xm
OpenOnSearch_FRAMEWORKS = UIKit
THEOS_BUILD_DIR = debs

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"

