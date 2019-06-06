export THEOS_DEVICE_IP=192.168.1.7
export TARGET=iphone:clang

include theos/makefiles/common.mk

TWEAK_NAME = messageSwiper
messageSwiper_FILES = Tweak.xm
messageSwiper_FRAMEWORKS = UIKit QuartzCore Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
