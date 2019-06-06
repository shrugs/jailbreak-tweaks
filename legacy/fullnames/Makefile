
export THEOS_DEVICE_IP=192.168.1.7
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = FullNames
FullNames_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

THEOS_BUILD_DIR = debs

after-install::
	install.exec "killall -9 backboardd"
