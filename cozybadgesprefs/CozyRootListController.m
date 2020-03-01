#include "CozyHeaders.h"
#include "../source/CozyBadges.h"

@implementation CozyRootListController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) self.navigationItem.navigationBar.tintColor = nil;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];

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

-(void)_returnKeyPressed:(id)arg1 {
	[self.view endEditing:YES];
	[super _returnKeyPressed:arg1];
}

@end
