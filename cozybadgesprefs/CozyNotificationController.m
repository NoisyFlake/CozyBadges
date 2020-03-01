#include "CozyHeaders.h"
#include "../source/CozyBadges.h"

@implementation CozyNotificationController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Notification" target:self] mutableCopy];

        CozyPrefs *prefs = [CozyPrefs sharedInstance];

        for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
            if (
                (spec.properties[@"depends"] && ![prefs boolForKey:spec.properties[@"depends"]]) || 
                (spec.properties[@"dependsNot"] && [prefs boolForKey:spec.properties[@"dependsNot"]])
            ) {
                [mutableSpecifiers removeObject:spec];
            } 
        }

        _specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

@end
