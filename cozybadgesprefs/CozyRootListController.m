#include "CozyHeaders.h"

@implementation CozyRootListController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) self.navigationItem.navigationBar.tintColor = nil;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	NSLog(@"CozyBadges: GOT IT");

	// Remove dockHideLabels entry if FloatingDock is installed
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/FloatingDock.dylib"] || [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/FloatingDockPlus.dylib"]) {
		NSMutableArray *mutableArray = [_specifiers mutableCopy];
		for (PSSpecifier *spec in _specifiers) {
			if ([spec.properties[@"id"] isEqual:@"dockHideLabels"]) {
				[mutableArray removeObject:spec];
			}
		}
		_specifiers = mutableArray;
	}

	return _specifiers;
}

-(void)setBackgroundEnabled:(id)value specifier:(PSSpecifier *)specifier {
    if([value boolValue]) {
    	[self setPreferenceValue:@(NO) specifier:[self specifierForID:@"textEnabled"]];
    }

    [self setPreferenceValue:value specifier:specifier];
    [self reload];
}

-(void)setTextEnabled:(id)value specifier:(PSSpecifier *)specifier {
    if([value boolValue]) {
    	[self setPreferenceValue:@(NO) specifier:[self specifierForID:@"backgroundEnabled"]];
    }

    [self setPreferenceValue:value specifier:specifier];
    [self reload];
}

-(void)_returnKeyPressed:(id)arg1 {
	[self.view endEditing:YES];
	[super _returnKeyPressed:arg1];
}

@end
