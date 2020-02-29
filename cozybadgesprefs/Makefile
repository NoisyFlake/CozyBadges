TARGET = iphone:clang:11.2:11.2
ARCHS = arm64
ifeq ($(shell uname -s),Darwin)
	ARCHS += arm64e
endif

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CozyBadgesPrefs

$(BUNDLE_NAME)_FILES =  ../source/CBColors.m $(wildcard *.m *.xm CustomCells/*.m)
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc
$(BUNDLE_NAME)_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CozyBadgesPrefs.plist$(ECHO_END)
