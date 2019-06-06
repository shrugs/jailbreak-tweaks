include $(THEOS)/makefiles/common.mk

TWEAK_NAME = twitchplayspokemongo
twitchplayspokemongo_FILES = Tweak.xm
twitchplayspokemongo_FRAMEWORKS = CoreLocation
twitchplayspokemongo_LDFLAGS = -lsimulatetouch -lrocketbootstrap

SUBPROJECTS += growlith

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
