# export TARGET=iphone:clang
export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2222
ARCHS = armv7 arm64
include theos/makefiles/common.mk
TARGET := iphone:7.0:2.0

TWEAK_NAME = NoPhantomAds
NoPhantomAds_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
THEOS_BUILD_DIR = debs

after-install::
	install.exec "killall -9 backboardd"

