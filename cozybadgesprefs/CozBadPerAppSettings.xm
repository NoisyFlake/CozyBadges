#import "CozBadPerAppSettings.h"

@implementation CozBadPerAppSettings

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.navigationBar.tintColor = [UIColor colorWithRed:0.38 green:0.56 blue:0.76 alpha:1.0];

	UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = applyButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.38 green:0.56 blue:0.76 alpha:1.0];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *appSpecifiers = [NSMutableArray array];

		NSMutableDictionary *userApps = [[NSMutableDictionary alloc] init];
		NSMutableDictionary *systemApps = [[NSMutableDictionary alloc] init];

		NSArray *apps = [[%c(LSApplicationWorkspace) defaultWorkspace] allInstalledApplications];
		for (LSApplicationProxy *app in apps) {
			if ([app.applicationType isEqual:@"User"]) {
				[userApps setObject:[app localizedNameForContext:nil] forKey:app.applicationIdentifier];
			} else if ([app.applicationType isEqual:@"System"]
				&& ![app.appTags containsObject:@"hidden"]
				&& !app.launchProhibited
				&& !app.placeholder
				&& !app.removedSystemApp) {
				[systemApps setObject:[app localizedNameForContext:nil] forKey:app.applicationIdentifier];
			}
		}

		[appSpecifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"App Store" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];

		NSArray *userAppsSorted = [userApps keysSortedByValueUsingSelector:@selector(compare:)];
		for(NSString *key in userAppsSorted) {
			[appSpecifiers addObject:[self generateSpecifier:key displayName:[userApps objectForKey:key]]];
		}

		[appSpecifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"System" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];

		NSArray *systemAppsSorted = [systemApps keysSortedByValueUsingSelector:@selector(compare:)];
		for(NSString *key in systemAppsSorted) {
			[appSpecifiers addObject:[self generateSpecifier:key displayName:[systemApps objectForKey:key]]];
		}

		_specifiers = appSpecifiers;

	}

	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	HBLogWarn(@"Setter called: %@ %@", path, value);

	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
}

- (BOOL)isValueSet:(NSString *)key {
	NSString *path = @"/User/Library/Preferences/com.noisyflake.cozybadgesprefs.plist";
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	NSString *singularKey = [NSString stringWithFormat:@"nameSingular_%@", key];
	NSString *pluralKey = [NSString stringWithFormat:@"namePlural_%@", key];

	return ([settings[singularKey] length] > 0 || [settings[pluralKey] length] > 0);
}

-(void)save {
	[self.view endEditing:YES];
	[super _returnKeyPressed:nil];

	[self reloadSpecifiers];
}

- (void)loadInputFields:(PSSpecifier*)specifier {
	if ([specifier.properties[@"isOpen"] length] > 0) return;
	[specifier setProperty:@(YES) forKey:@"isOpen"];

	PSTextFieldSpecifier* plural = [PSTextFieldSpecifier preferenceSpecifierNamed:@"Plural:"
									    target:self
									    set:@selector(setPreferenceValue:specifier:)
								   		get:@selector(readPreferenceValue:)
									    detail:Nil
									    cell:PSEditTextCell
									    edit:Nil];

	[plural setProperty:[NSString stringWithFormat:@"namePlural_%@", specifier.properties[@"key"]] forKey:@"key"];
	[plural setProperty:@"com.noisyflake.cozybadgesprefs" forKey:@"defaults"];
	[plural setPlaceholder:@"@ Messages"];

	PSTextFieldSpecifier* singular = [PSTextFieldSpecifier preferenceSpecifierNamed:@"Singular:"
									    target:self
									    set:@selector(setPreferenceValue:specifier:)
								   		get:@selector(readPreferenceValue:)
									    detail:Nil
									    cell:PSEditTextCell
									    edit:Nil];

	[singular setProperty:[NSString stringWithFormat:@"nameSingular_%@", specifier.properties[@"key"]] forKey:@"key"];
	[singular setProperty:@"com.noisyflake.cozybadgesprefs" forKey:@"defaults"];
	[singular setPlaceholder:@"@ Message"];

	[self insertSpecifier:singular afterSpecifier:specifier animated:YES];
	[self insertSpecifier:plural afterSpecifier:singular animated:YES] ;
}

- (PSSpecifier*)generateSpecifier:(NSString *)key displayName:(NSString *)displayName {
	PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:displayName
									    target:self
									    set:nil
								   		get:nil
									    detail:Nil
									    cell:PSButtonCell
									    edit:Nil];

	[specifier setProperty:key forKey:@"key"];
	[specifier setProperty:@"com.noisyflake.cozybadges" forKey:@"defaults"];

	if ([self isValueSet:key]) {
		[specifier setProperty:NSClassFromString(@"CozBadButtonCell") forKey:@"cellClass"];
	} else {
		[specifier setProperty:NSClassFromString(@"CozBadGreyButtonCell") forKey:@"cellClass"];
	}

	specifier.buttonAction = @selector(loadInputFields:);
	return specifier;
}

@end


