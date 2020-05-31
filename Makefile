TARGET = iphone:clang:11.2:11.2
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CozyBadges
$(TWEAK_NAME)_FILES = $(wildcard source/*.x source/*.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += cozybadgesprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
