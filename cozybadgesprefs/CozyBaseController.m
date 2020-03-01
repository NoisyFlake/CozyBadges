#include "CozyHeaders.h"
#include "../source/CozyBadges.h"
#include "../source/NSLog.h"
#import <spawn.h>

CozyPrefs *prefs;

@implementation CozyBaseController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.navigationBar.tintColor = kCOZYCOLOR;

    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
	self.navigationItem.rightBarButtonItem = applyButton;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[settings setObject:value forKey:specifier.properties[@"key"]];

	if ([specifier.properties[@"key"] isEqual:@"dockHideLabels"] && ![value boolValue]) {
		[settings setObject:@YES forKey:@"dockRaiseLabels"];
	}

	[settings writeToFile:path atomically:YES];

	if (specifier.properties[@"refresh"]) [self updateSpecifiers];
}

- (void)updateSpecifiers {
	prefs = [CozyPrefs sharedInstance];

	int i = 0;

	for (PSSpecifier *savedSpec in self.savedSpecifiers) {
		BOOL visible = [self isSpecifierVisible:savedSpec];

		if ([[self specifiers] containsObject:savedSpec]) {
			if (!visible) [self removeSpecifier:savedSpec animated:YES];
		} else {
			PSSpecifier *insertAfter = [[self specifiers] containsObject:[self.savedSpecifiers objectAtIndex:i-1]] ? [self.savedSpecifiers objectAtIndex:i-1] : [[self specifiers] lastObject];
			if (visible) [self insertSpecifier:savedSpec afterSpecifier:insertAfter animated:YES];
		}
		i++;
	}

	// This is necessary to redraw the header (iOS is so weird sometimes).
	if ([self isKindOfClass:[CozyRootListController class]]) [self reloadSpecifiers];
}

- (NSArray *)dynamicSpecifiersFromPlist:(NSString *)plist {
	NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:plist target:self] mutableCopy];
	self.savedSpecifiers = [mutableSpecifiers copy];

	prefs = [CozyPrefs sharedInstance];

	for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
		if (![self isSpecifierVisible:spec]) [mutableSpecifiers removeObject:spec];
	}

	return mutableSpecifiers;
}

- (BOOL)isSpecifierVisible:(PSSpecifier *)specifier {
	BOOL visible = YES;

	if (specifier.properties[@"depends"] && ![prefs boolForKey:specifier.properties[@"depends"]]) visible = NO;
	if (specifier.properties[@"dependsNot"] && [prefs boolForKey:specifier.properties[@"dependsNot"]]) visible = NO;
	if (specifier.properties[@"labelDependant"] && [prefs boolForKey:@"hideLabels"] && [prefs boolForKey:@"dockHideLabels"]) visible = NO;

	if ((![prefs valueForKey:@"regularMode"] || [[prefs valueForKey:@"regularMode"] isEqual:@"none"]) && ([specifier.properties[@"key"] isEqual:@"regularAutoColor"] || [specifier.properties[@"key"] isEqual:@"regularColor"])) visible = NO;
	if ([[prefs valueForKey:@"notificationMode"] isEqual:@"none"] && ([specifier.properties[@"key"] isEqual:@"notificationAutoColor"] || [specifier.properties[@"key"] isEqual:@"notificationColor"])) visible = NO;

	return visible;
}

-(void)respring {
	[self.view endEditing:YES];

	pid_t pid;
	const char* args[] = {"sbreload", NULL};
	posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
}

@end
