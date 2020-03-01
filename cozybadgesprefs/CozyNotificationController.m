#include "CozyHeaders.h"

@implementation CozyNotificationController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self dynamicSpecifiersFromPlist:@"Notification"];
	}

	return _specifiers;
}

-(void)_returnKeyPressed:(id)arg1 {
	[self.view endEditing:YES];
	[super _returnKeyPressed:arg1];
}

@end
