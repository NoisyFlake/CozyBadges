/*

	CozyBadges
	Replace notification badges with sleek labels

	Copyright (C) 2019 by NoisyFlake

	All Rights Reserved

*/

#import "CozyBadges.h"
#import "CBColors.h"

NSMutableDictionary *prefs, *defaultPrefs;

%hook SBIconView
	-(SBIconLabelImageParameters *)_labelImageParameters {
		SBIconLabelImageParameters *params = %orig;

		// Overwrite with our own initMethod to pass the icon to it
		return params ? [[%c(CBIconLabelImageParameters) alloc] initWithParameters:params icon:[self icon]] : nil;
	}

	-(void)_updateAccessoryViewWithAnimation:(BOOL)arg1 {
		// Disable legibility settings for active labels (prevents iOS from darkening the label on a bright wallpaper)
		_UILegibilitySettings* settings = [[self icon] badgeValue] > 0 ? nil : [self legibilitySettings];

		SBIconLabelImageParameters *params = [self _labelImageParameters];
		SBIconLabelView *labelView = MSHookIvar<SBIconLabelView *>(self, "_labelView");

		if(params != nil && labelView != nil) {
			// Apply legibility settings to the label if necessary
			[labelView updateIconLabelWithSettings:settings imageParameters:params];

			SBIconLabelView *imageView = (SBIconLabelView *)([labelView respondsToSelector:@selector(imageView)] ? labelView.imageView : labelView);
			SBIconLabelImage *newImage = [%c(SBIconLabelImage) imageWithParameters:params];
			[imageView setImage:newImage];

			// Recalculate width of the label in case the text changed
			CGRect frame = imageView.frame;
			frame.size = newImage.size;
			[imageView setFrame:frame];

			// Don't hide dock labels
			if([labelView isKindOfClass:%c(SBIconLegibilityLabelView)]) {
				labelView.hidden = NO;
			}

		}

		%orig;
	}

	-(BOOL)isLabelHidden {
		return NO;
	}

	-(BOOL)allowsLabelArea {
		return YES;
	}

	-(void)_createAccessoryViewIfNecessary {
		// Disable regular badges
		return;
	}
%end

%hook SBDockIconListView

	// Move icons in the dock up to make space for the labels
	-(CGPoint)originForIconAtCoordinate:(SBIconCoordinate)arg1 metrics:(const id*)arg2 {
	    CGPoint point = %orig;
	    NSArray *icons = [self icons];

	    NSUInteger count = 1;
	    for(SBIcon *icon in icons) {
	        if (count == arg1.col) {
	            // This is the icon we are currently setting the origin for
	            if ([icon badgeValue] > -1) {
	                CGPoint newPoint = CGPointMake(point.x, point.y - 8);
	                return newPoint;
	            }
	        }

	        count++;
	    }

	    return %orig;
	}

%end

%subclass CBIconLabelImageParameters : SBIconLabelImageParameters
	%property (nonatomic, retain) SBIcon *icon;
	%property (nonatomic, retain) SBIcon *folderIcon;

	%new
	-(id)initWithParameters:(SBIconLabelImageParameters *)params icon:(SBIcon *)icon {
		self = [self initWithParameters:params];

		self.icon = icon;
		self.folderIcon = [icon isFolderIcon] ? [self iconForFolder:icon] : nil;

		return self;
	}

	-(void)dealloc {
		self.icon = nil;
		%orig;
	}

	%new
	-(SBIcon *)iconForFolder:(SBFolderIcon *)folderIcon {
	    SBIcon *ret = nil;

	    for(SBIcon *icon in [[folderIcon folder] allIcons]) {
	        if(ret == nil) {
	            ret = icon;
	        } else if([icon badgeValue] > [ret badgeValue]) {
	            ret = icon;
	        }
	    }

	    return ret;
	}

	-(BOOL)isColorspaceGrayscale {
		return NO;
	}

	-(UIColor *)focusHighlightColor {
		if ([self.icon badgeValue] > 0) {
			SBIcon *actualIcon = self.folderIcon != nil ? self.folderIcon : self.icon;
			UIColor *avgColor = [[actualIcon unmaskedIconImageWithInfo:nil] averageColor];
			return avgColor;
		}

		return %orig;
	}

	-(NSString *)text {
		if ([self.icon badgeValue] > 0) {
			return [NSString stringWithFormat:@"%lld Nachricht%@", [self.icon badgeValue], [self.icon badgeValue] > 1 ? @"en" : @""];
		};

		return %orig;
	}

%end

// ----- PREFERENCE HANDLING ----- //

static BOOL getBool(NSString *key) {
	id ret = [prefs objectForKey:key];

	if(ret == nil) {
		ret = [defaultPrefs objectForKey:key];
	}

	return [ret boolValue];
}

// static NSString* getValue(NSString *key) {
// 	return [prefs objectForKey:key] ?: [defaultPrefs objectForKey:key];
// }

static void loadPrefs() {
	prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.noisyflake.cozybadgesprefs.plist"];
}

static void initPrefs() {
	// Copy the default preferences file when the actual preference file doesn't exist
	NSString *path = @"/User/Library/Preferences/com.noisyflake.cozybadgesprefs.plist";
	NSString *pathDefault = @"/Library/PreferenceBundles/CozyBadgesPrefs.bundle/defaults.plist";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager copyItemAtPath:pathDefault toPath:path error:nil];
	}
}

%ctor {
	initPrefs();
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.noisyflake.cozybadgesprefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);

	if (getBool(@"enabled")) {
		%init(_ungrouped);
		HBLogWarn(@"----- CozyBadges loaded -----");
	}
}
