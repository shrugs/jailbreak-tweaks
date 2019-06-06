# Uses TouchID, restricted to (>= 5S)
ARCHS = arm64

include theos/makefiles/common.mk

TWEAK_NAME = Glimpse
Glimpse_FILES = Tweak.xm
Glimpse_LIBRARIES = activator
# Glimpse_LDFLAGS = -lactivator
include $(THEOS_MAKE_PATH)/tweak.mk

THEOS_BUILD_DIR = debs
# SUBPROJECTS += glimpsesettings
# include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
