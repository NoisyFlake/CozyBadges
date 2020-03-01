#include "CozyHeaders.h"

@implementation CozyRootListController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) self.navigationItem.navigationBar.tintColor = nil;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self dynamicSpecifiersFromPlist:@"Root"];
	}

	return _specifiers;
}

-(void)_returnKeyPressed:(id)arg1 {
	[self.view endEditing:YES];
	[super _returnKeyPressed:arg1];
}

@end
