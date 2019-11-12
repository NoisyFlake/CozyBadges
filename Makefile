TARGET = iphone:11.2
ARCHS = arm64
ifeq ($(shell uname -s),Darwin)
	ARCHS += arm64e
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CozyBadges

CozyBadges_FILES = Tweak.x
CozyBadges_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
