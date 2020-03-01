#include "CozyHeaders.h"

@implementation CozyNotificationController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self dynamicSpecifiersFromPlist:@"Notification"];
	}

	return _specifiers;
}

@end
