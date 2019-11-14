/*

	CozyBadges
	Replace notification badges with sleek labels

	Copyright (C) 2019 by NoisyFlake

	All Rights Reserved

*/

#import "CozyBadges.h"
#import "CBColors.h"

NSMutableDictionary *prefs, *defaultPrefs;
struct SBIconImageInfo imageInfo;

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

			// Hide or show label
			if([labelView isKindOfClass:%c(SBIconLegibilityLabelView)]) {
				if ([self.location isEqual:@"SBIconLocationDock"]) {
					labelView.hidden = !(getBool(@"dockEnabled") && (!getBool(@"dockHideLabels") || [[self icon] badgeValue] > 0));

					if (getBool(@"dockEnabled") && getBool(@"dockHideLabels")) {
						// We might need to raise or lower icons in the dock, this calls originForIconAtCoordinate
						SBRootFolderController *controller = [self _viewControllerForAncestor];
						if ([controller isMemberOfClass:%c(SBRootFolderController)]) {
							[[controller dockIconListView] setIconsNeedLayout];
						}
					}

				} else {
					labelView.hidden = (getBool(@"hideLabels") && [[self icon] badgeValue] <= 0);
				}
			} else {
				// Always hide SBIconSimpleLabelViews as they are the duplicated dock labels
				labelView.hidden = YES;
			}
		}

		%orig;

	}

	-(BOOL)allowsLabelArea {
		// Allow labels in the dock
		if ([self.location isEqual:@"SBIconLocationDock"] && getBool(@"dockEnabled")) {
			return YES;
		}

		return %orig;
	}


	-(void)_createAccessoryViewIfNecessary {
		if ([self.location isEqual:@"SBIconLocationDock"] && !getBool(@"dockEnabled")) {
			%orig;
		}

		// Disable regular badges
		return;
	}
%end

%hook SBDockIconListView

	// Move icons in the dock up to make space for the labels
	-(CGPoint)originForIconAtCoordinate:(SBIconCoordinate)arg1 metrics:(const id*)arg2 {
		if (!getBool(@"dockEnabled")) return %orig;

	    CGPoint point = %orig;
	    NSArray *icons = [self icons];

	    NSUInteger count = 1;
	    for(SBIcon *icon in icons) {
	        if (count == arg1.col) {
	            // This is the icon we are currently setting the origin for
	            if (!getBool(@"dockHideLabels") || [icon badgeValue] > 0) {
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
		self.folderIcon = nil;

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
		UIColor *color = %orig;

		if([self.icon badgeValue] > 0) {

			if (getBool(@"backgroundEnabled")) {
				if (getBool(@"backgroundAutoColor")) {
					SBIcon *actualIcon = self.folderIcon != nil ? self.folderIcon : self.icon;
					color = [[actualIcon unmaskedIconImageWithInfo:imageInfo] averageColor];
				} else {
					color = [UIColor RGBAColorFromHexString:getValue(@"backgroundColor")];
				}
			}

		}

		return color;
	}

	-(UIColor *)textColor {
		UIColor *color = %orig;

		if ([self.icon badgeValue] > 0) {

			if (getBool(@"textEnabled")) {
				if (getBool(@"textAutoColor")) {
					SBIcon *actualIcon = self.folderIcon != nil ? self.folderIcon : self.icon;
					color = [[actualIcon unmaskedIconImageWithInfo:imageInfo] averageColor];
				} else {
					color = [UIColor RGBAColorFromHexString:getValue(@"textColor")];
				}
			} else if (getBool(@"backgroundEnabled")) {
				color = [[self focusHighlightColor] isDarkColor] ? [UIColor whiteColor] : [UIColor blackColor];
			}

		}

		return color;
	}

	-(NSString *)text {
		NSString *text = %orig;

		if ([self.icon badgeValue] > 0) {

			if (getBool(@"nameEnabled")) {
				if ([self.icon badgeValue] > 1) {
					text = [getValue(@"namePlural") length] > 0 ? getValue(@"namePlural") : @"@ Messages";
				} else {
					text = [getValue(@"nameSingular") length] > 0 ? getValue(@"nameSingular") : @"@ Message";
				}

				// Replace @ with the actual badgeValue
				text = [text stringByReplacingOccurrencesOfString:@"@" withString:[NSString stringWithFormat:@"%lld", [self.icon badgeValue]]];
			}

		}

		return text;
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

static NSString* getValue(NSString *key) {
	return [prefs objectForKey:key] ?: [defaultPrefs objectForKey:key];
}

static void initPrefs() {
	// Copy the default preferences file when the actual preference file doesn't exist
	NSString *path = @"/User/Library/Preferences/com.noisyflake.cozybadgesprefs.plist";
	NSString *pathDefault = @"/Library/PreferenceBundles/CozyBadgesPrefs.bundle/defaults.plist";

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager copyItemAtPath:pathDefault toPath:path error:nil];
	}

	prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	defaultPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:pathDefault];

	// Fill imageInfo - no idea what optionA or optionB is, but 2/0 seems to do the trick to get the desired image
	imageInfo.size = CGSizeMake(30, 30);
	imageInfo.optionA = 2;
	imageInfo.optionB = 0;
}

%ctor {
	initPrefs();

	if (getBool(@"enabled")) {
		%init(_ungrouped);
		HBLogWarn(@"----- CozyBadges loaded -----");
	}
}
