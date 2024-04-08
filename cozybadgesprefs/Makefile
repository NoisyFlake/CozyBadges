TARGET = iphone:clang:latest
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CozyBadgesPrefs

$(BUNDLE_NAME)_FILES =  ../source/CBColors.m ../source/CozyPrefs.m $(wildcard *.m *.xm CustomCells/*.m)
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc -DPACKAGE_VERSION='@"$(THEOS_PACKAGE_BASE_VERSION)"' -DFINAL='$(FINAL)'
$(BUNDLE_NAME)_LIBRARIES = colorpicker

ifeq ($(THEOS_PACKAGE_SCHEME), rootless)
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc -Wno-incomplete-implementation -DTHEOS_PACKAGE_SCHEME=rootless -DPACKAGE_VERSION='@"$(THEOS_PACKAGE_BASE_VERSION)"' -DFINAL='$(FINAL)'
endif

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CozyBadgesPrefs.plist$(ECHO_END)
