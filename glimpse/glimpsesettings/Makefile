include theos/makefiles/common.mk

BUNDLE_NAME = GlimpseSettings
GlimpseSettings_FILES = GlimpseSettings.mm
GlimpseSettings_INSTALL_PATH = /Library/PreferenceBundles
GlimpseSettings_FRAMEWORKS = UIKit
GlimpseSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/GlimpseSettings.plist$(ECHO_END)
