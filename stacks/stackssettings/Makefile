include theos/makefiles/common.mk

BUNDLE_NAME = stacksSettings
stacksSettings_FILES = stacksSettings.mm
stacksSettings_INSTALL_PATH = /Library/PreferenceBundles
stacksSettings_FRAMEWORKS = UIKit
stacksSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk


internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/stacks$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/stacks/stacksSettings.plist$(ECHO_END)
