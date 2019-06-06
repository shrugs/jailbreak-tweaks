include $(THEOS)/makefiles/common.mk

TWEAK_NAME = growlith
growlith_FILES = Tweak.xm
growlith_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
