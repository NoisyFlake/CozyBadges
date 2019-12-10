#include "CozBadRootListController.h"
#include "NSTask.h"
#import <spawn.h>

UIColor *originalTintColor = nil;

@implementation CozBadRootListController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    originalTintColor = self.navigationItem.navigationBar.tintColor;
    self.navigationItem.navigationBar.tintColor = [UIColor colorWithRed:0.38 green:0.56 blue:0.76 alpha:1.0];

    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
	self.navigationItem.rightBarButtonItem = applyButton;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.navigationItem.navigationBar.tintColor = originalTintColor;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

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

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
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

-(void)openReddit {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"reddit:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"reddit:///u/NoisyFlake"] options:@{} completionHandler:nil];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"apollo:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"apollo://www.reddit.com/u/NoisyFlake"] options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.reddit.com/u/NoisyFlake"] options:@{} completionHandler:nil];
    }
}

-(void)openTwitter {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/NoisyFlake"] options:@{} completionHandler:nil];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=NoisyFlake"] options:@{} completionHandler:nil];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=NoisyFlake"] options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/NoisyFlake"] options:@{} completionHandler:nil];
    }
}

-(void)respring {
	[self.view endEditing:YES];

	pid_t pid;
	const char* args[] = {"sbreload", NULL};
	posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
}

@end

@implementation CozBadLogo

- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Banner" specifier:specifier];
	if (self) {
		CGFloat width = 320;
		CGFloat height = 70;

		CGRect backgroundFrame = CGRectMake(-50, -35, width+50, height);
		UILabel *background = [[UILabel alloc] initWithFrame:backgroundFrame];
		[background layoutIfNeeded];
		background.backgroundColor = [UIColor colorWithRed:0.38 green:0.56 blue:0.76 alpha:1.0];
		background.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[self addSubview:background];

		CGRect tweakNameFrame = CGRectMake(0, -40, width, height);
		UILabel *tweakName = [[UILabel alloc] initWithFrame:tweakNameFrame];
		[tweakName layoutIfNeeded];
		tweakName.numberOfLines = 1;
		tweakName.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.0f];
		tweakName.textColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.9];
		tweakName.text = @"CozyBadges";
		tweakName.textAlignment = NSTextAlignmentCenter;
		[self addSubview:tweakName];

		CGRect versionFrame = CGRectMake(0, -5, width, height);
		version = [[UILabel alloc] initWithFrame:versionFrame];
		version.numberOfLines = 1;
		version.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		version.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
		version.textColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.5];
		version.backgroundColor = [UIColor clearColor];
		version.textAlignment = NSTextAlignmentCenter;
		version.text = @"Version unknown";
		version.alpha = 0;
		[self addSubview:version];

		dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSPipe *pipe = [NSPipe pipe];

			NSTask *task = [[NSTask alloc] init];
			task.arguments = @[@"-c", @"dpkg -s com.noisyflake.cozybadges | grep -i version | cut -d' ' -f2"];
			task.launchPath = @"/bin/sh";
			[task setStandardOutput: pipe];
			[task launch];
			[task waitUntilExit];

			NSFileHandle *file = [pipe fileHandleForReading];
			NSData *output = [file readDataToEndOfFile];
			NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
			[file closeFile];

			dispatch_async(dispatch_get_main_queue(), ^(void){
				// Update label on the main queue
				if ([outputString length] > 0) {
					version.text = [NSString stringWithFormat:@"Version %@", outputString];
				}

				[UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
					version.alpha = 1;
				} completion:nil];
			});
		});

	}
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return 100.0f;
}
@end

