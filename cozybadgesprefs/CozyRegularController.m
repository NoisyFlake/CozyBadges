#include "CozyHeaders.h"

@implementation CozyRegularController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self dynamicSpecifiersFromPlist:@"Regular"];
	}

	return _specifiers;
}

@end
