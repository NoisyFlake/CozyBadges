#import "NSLog.h"
#import "CozyBadges.h"

static CozyPrefs *sharedInstance = nil;

static NSString *settingsFile = @"/User/Library/Preferences/com.noisyflake.cozybadgesprefs.plist";
static NSString *defaultFile = @"/Library/PreferenceBundles/CozyBadgesPrefs.bundle/defaults.plist";

@implementation CozyPrefs

+(id)sharedInstance {
	if (sharedInstance == nil) {
		NSLog(@"Initializing preferences.");
		sharedInstance = [[self alloc] init];
	} else {
		[sharedInstance reloadPreferences];
	}

	return sharedInstance;
}

-(id)init {
	self = [super init];

	if (self) {
		// Copy the default preferences file if the actual preference file doesn't exist
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:settingsFile]) {
			[fileManager copyItemAtPath:defaultFile toPath:settingsFile error:nil];
		}

		_defaultSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:defaultFile];
		_settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsFile];

		NSLog(@"Preferences loaded.");
	}

	return self;
}

-(void)reloadPreferences {
	NSLog(@"Preferences reloaded");
	_settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsFile];
}

-(BOOL)boolForKey:(NSString *)key {
	if ([key isEqual:@"dockHideLabels"] && [%c(SBFloatingDockController) isFloatingDockSupported]) {
		return YES;
	}
	
	id ret = _settings[key] ?: _defaultSettings[key];
	return [ret boolValue];
}

-(NSString *)valueForKey:(NSString *)key {
	return _settings[key] ?: _defaultSettings[key];
}

@end
