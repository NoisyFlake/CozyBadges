/*

	CozyBadges
	A cozy place for your badges

	Copyright (C) 2020 by NoisyFlake

	All Rights Reserved

*/

#import "NSLog.h"
#import "CozyBadges.h"
#import "CBColors.h"

CozyPrefs *settings;
NSMutableDictionary *colorCache;

struct SBIconImageInfo imageInfo;

%hook SBIconSimpleLabelView
	-(void)setFrame:(CGRect)frame {
		bool isInDock = [self.iconView.location isEqual:@"SBIconLocationDock"] || [self.iconView.location isEqual:@"SBIconLocationFloatingDock"];
		frame.origin.y += [[settings valueForKey:(isInDock ? @"labelOffsetDock" : @"labelOffset")] floatValue];

		%orig;
	}
%end

%hook SBIconLegibilityLabelView
	-(void)setFrame:(CGRect)frame {
		bool isInDock = [self.iconView.location isEqual:@"SBIconLocationDock"] || [self.iconView.location isEqual:@"SBIconLocationFloatingDock"];
		frame.origin.y += [[settings valueForKey:(isInDock ? @"labelOffsetDock" : @"labelOffset")] floatValue];

		%orig;
	}
%end

%hook SBIconView
	-(SBIconLabelImageParameters *)_labelImageParameters {
		SBIconLabelImageParameters *params = %orig;

		// Overwrite with our own initMethod to pass the icon to it
		return params ? [[%c(CBIconLabelImageParameters) alloc] initWithParameters:params icon:[self icon]] : nil;
	}

	-(void)layoutSubviews {
		// Disable legibility settings for active labels (prevents iOS from darkening the label on a bright wallpaper)
		_UILegibilitySettings* legibilitySettings = [[self icon] badgeValue] > 0 ? nil : [self legibilitySettings];

		SBIconLabelImageParameters *params = [self _labelImageParameters];
		SBIconLabelView *labelView = self.labelView;

		if(params == nil || labelView == nil) return %orig;

		//Floating dock uses SimpleLabelViews for whatever reason
		if([labelView isKindOfClass:%c(SBIconLegibilityLabelView)] || [self.location isEqual:@"SBIconLocationFloatingDock"]) {

			// Hide or show label
			if (isIconInDock && [settings boolForKey:@"dockEnabled"]) {
				labelView.hidden = ([settings boolForKey:@"dockHideLabels"] &&
					(![[%c(SBIconController) sharedInstance] allowsBadgingForIcon:[self icon]] || [[self icon] badgeValue] <= 0));

				// We might need to raise or lower icons in the dock, this calls originForIconAtCoordinate
				UIViewController *controller = [self _viewControllerForAncestor];
				if ([controller isMemberOfClass:%c(SBRootFolderController)]) {
					[[(SBRootFolderController *)controller dockIconListView] setIconsNeedLayout];
				} else if ([controller isMemberOfClass:%c(SBFloatingDockViewController)]) {
					[[(SBFloatingDockViewController *)controller currentIconListView] setIconsNeedLayout];
				}

			} else if (!isIconInDock) {
				labelView.hidden = ([settings boolForKey:@"hideLabels"] &&
					(![[%c(SBIconController) sharedInstance] allowsBadgingForIcon:[self icon]] || [[self icon] badgeValue] <= 0));
			}

		} else {
			// Hide SBIconSimpleLabelViews as they are the duplicated, nonsense dock labels
			labelView.hidden = YES;
		}

		if (!labelView.hidden) {
			// Apply legibility settings to the label if necessary
			[labelView updateIconLabelWithSettings:legibilitySettings imageParameters:params];

			// Update the actual label so that it displays the desired information
			SBIconLabelView *imageView = (SBIconLabelView *)([labelView respondsToSelector:@selector(imageView)] ? labelView.imageView : labelView);
			SBIconLabelImage *newImage = [%c(SBIconLabelImage) imageWithParameters:params];
			[imageView setImage:newImage];

			// Disable the shadow behind the image that gets only drawn on respring
			if ([labelView respondsToSelector:@selector(shadowImageView)]) labelView.shadowImageView.hidden = YES;

			// Recalculate width of the label in case the text changed
			CGRect frame = imageView.frame;
			frame.size = newImage.size;
			[imageView setFrame:frame];
		}

		%orig;

	}

	-(BOOL)allowsLabelArea {
		// Allow labels in the dock
		if (isIconInDock && [settings boolForKey:@"dockEnabled"]) {
			return YES;
		}

		return %orig;
	}

	-(void)_createAccessoryViewIfNecessary {
		// Only show regular badges in the dock if desired
		if (isIconInDock && ![settings boolForKey:@"dockEnabled"]) %orig;
	}

	-(BOOL)allowsLabelAccessoryView {
		return NO;
	}

%end

%hook SBDockIconListView

	// Move icons in the dock up to make space for the labels
	-(CGPoint)originForIconAtCoordinate:(SBIconCoordinate)arg1 metrics:(const id*)arg2 {
		if (![settings boolForKey:@"dockEnabled"]) return %orig;

		CGPoint point = %orig;
		NSArray *icons = [self icons];

		NSUInteger count = 1;
		for(SBIcon *icon in icons) {
			if (count == arg1.col) {
				// This is the icon we are currently setting the origin for
				if ([settings boolForKey:@"dockRaiseLabels"] ||
					([[%c(SBIconController) sharedInstance] allowsBadgingForIcon:icon] && [icon badgeValue] > 0)) {
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
	%property (nonatomic, assign) BOOL hasNotification;
	%property (nonatomic, assign) int folderNotificationApps;
	%property (nonatomic, retain) UIColor *dominantColor;

	%new
	-(id)initWithParameters:(SBIconLabelImageParameters *)params icon:(SBIcon *)icon {
		self = [self initWithParameters:params];

		self.hasNotification = (icon != nil && [[%c(SBIconController) sharedInstance] allowsBadgingForIcon:icon] && [icon badgeValue] > 0);

		self.icon = icon;
		self.folderIcon = [icon isFolderIcon] ? [self iconForFolder:icon] : nil;
		self.dominantColor = nil;

		self.folderNotificationApps = 0;
		if ([icon isFolderIcon]) {
			for(SBIcon *fIcon in [[((SBFolderIcon *)self.icon) folder] allIcons]) {
				if (![[%c(SBIconController) sharedInstance] allowsBadgingForIcon:fIcon]) continue;
				if ([fIcon badgeValue] > 0) self.folderNotificationApps++;
			}
		}

		return self;
	}

	%new
	-(SBIcon *)iconForFolder:(SBFolderIcon *)folderIcon {
		SBIcon *ret = nil;

		for(SBIcon *icon in [[folderIcon folder] allIcons]) {
			if (![[%c(SBIconController) sharedInstance] allowsBadgingForIcon:icon]) continue;

			if(ret == nil) {
				ret = icon;
			} else if([icon badgeValue] > [ret badgeValue]) {
				ret = icon;
			}
		}

		return ret;
	}

	%new
	-(UIColor *)cozyColorFor:(NSString *)mode {
		NSString *autoKey = nil, *manualKey = nil;

		if (self.hasNotification && [[settings valueForKey:@"notificationMode"] isEqual:mode]) {
			autoKey = @"notificationAutoColor";
			manualKey = @"notificationColor";
		} else if (!self.hasNotification && [[settings valueForKey:@"regularMode"] isEqual:mode]) {
			autoKey = @"regularAutoColor";
			manualKey = @"regularColor";
		} else {
			return nil;
		}

		if ([settings boolForKey:autoKey]) {
			if (!self.dominantColor) {
				if (!self.hasNotification && self.folderIcon) return UIColor.whiteColor;

				SBIcon *actualIcon = self.hasNotification && self.folderIcon != nil ? self.folderIcon : self.icon;
				UIImage *image = [actualIcon unmaskedIconImageWithInfo:imageInfo];

				NSString *iconIdentifier = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
				UIColor *color = colorCache[iconIdentifier];

				if (iconIdentifier != nil && color == nil) {
					color = [image cozyDominantColor];
					[colorCache setObject:color forKey:iconIdentifier];
				}

				self.dominantColor = color;
			}

			return self.dominantColor;
		} else {
			return [UIColor cozyRGBAColorFromHexString:[settings valueForKey:manualKey]];
		}
	}

	-(void)dealloc {
		self.icon = nil;
		self.folderIcon = nil;
		self.hasNotification = nil;

		%orig;
	}

	-(BOOL)isColorspaceGrayscale {
		return NO;
	}

	-(UIColor *)focusHighlightColor {
		return [self cozyColorFor:@"background"] ?: %orig;
	}

	-(UIColor *)textColor {
		if ([self focusHighlightColor]) {
			return [[self focusHighlightColor] cozyIsDarkColor] ? [UIColor whiteColor] : [UIColor blackColor];
		}

		return [self cozyColorFor:@"text"] ?: %orig;
	}

	-(NSString *)text {
		NSString *text = %orig;

		if (self.hasNotification) {

			if ([settings boolForKey:@"nameEnabled"]) {
				NSString *bundleID = self.folderIcon && self.folderNotificationApps == 1 ? self.folderIcon.applicationBundleID : self.icon.applicationBundleID; // Allow using the special text in case there's only 1 notification inside the folder
				if (self.folderIcon) NSLog(@"COUNT: %d", self.folderNotificationApps);

				if ([self.icon badgeValue] > 1) {
					if ([[settings valueForKey:[NSString stringWithFormat:@"namePlural_%@", bundleID]] length] > 0) {
						text = [settings valueForKey:[NSString stringWithFormat:@"namePlural_%@", bundleID]];
					} else {
						text = [[settings valueForKey:@"namePlural"] length] > 0 ? [settings valueForKey:@"namePlural"] : @"@ Messages";
					}
				} else {
					if ([[settings valueForKey:[NSString stringWithFormat:@"nameSingular_%@", bundleID]] length] > 0) {
						text = [settings valueForKey:[NSString stringWithFormat:@"nameSingular_%@", bundleID]];
					} else {
						text = [[settings valueForKey:@"nameSingular"] length] > 0 ? [settings valueForKey:@"nameSingular"] : @"@ Message";
					}
				}

				// Replace @ with the actual badgeValue
				text = [text stringByReplacingOccurrencesOfString:@"@" withString:[NSString stringWithFormat:@"%lld", [self.icon badgeValue]]];
			}

		}

		return text;
	}

%end

%ctor {
	settings = [CozyPrefs sharedInstance];

	if ([settings boolForKey:@"enabled"]) {
		// Fill imageInfo - no idea what optionA or optionB is, but 2/0 seems to do the trick to get the desired image
		imageInfo.size = CGSizeMake(30, 30);
		imageInfo.optionA = 2;
		imageInfo.optionB = 0;

		colorCache = [[NSMutableDictionary alloc] init];

		%init(_ungrouped);
	}
}
