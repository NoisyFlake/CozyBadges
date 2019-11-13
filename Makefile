TARGET = iphone:clang:11.2:11.2
ARCHS = arm64
ifeq ($(shell uname -s),Darwin)
	ARCHS += arm64e
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CozyBadges
$(TWEAK_NAME)_FILES = CozyBadges.xm CBColors.m
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += cozybadgesprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
