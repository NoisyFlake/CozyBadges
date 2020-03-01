#include "CozyHeaders.h"
#import <spawn.h>

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

	if ([specifier.properties[@"key"] isEqual:@"backgroundAlwaysEnabled"]) {
		[settings setObject:@NO forKey:@"textAlwaysEnabled"];
	} else if ([specifier.properties[@"key"] isEqual:@"textAlwaysEnabled"]) {
		[settings setObject:@NO forKey:@"backgroundAlwaysEnabled"];
	} else if ([specifier.properties[@"key"] isEqual:@"backgroundEnabled"]) {
		[settings setObject:@NO forKey:@"textEnabled"];
	} else if ([specifier.properties[@"key"] isEqual:@"textEnabled"]) {
		[settings setObject:@NO forKey:@"backgroundEnabled"];
	} else if ([specifier.properties[@"key"] isEqual:@"dockHideLabels"] && ![value boolValue]) {
		[settings setObject:@YES forKey:@"dockRaiseLabels"];
	}

	[settings writeToFile:path atomically:YES];

	if (specifier.properties[@"refresh"]) {
		[self reloadSpecifiers];
	}
}

-(void)respring {
	[self.view endEditing:YES];

	pid_t pid;
	const char* args[] = {"sbreload", NULL};
	posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
}

@end
