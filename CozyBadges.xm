/*

	CozyBadges
	Replace notification badges with sleek labels

	Copyright (C) 2019 by NoisyFlake

	All Rights Reserved

*/

#import "CozyBadges.h"
#import "CBColors.h"

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

	        SBIconLabelImage *labelImage = [%c(SBIconLabelImage) imageWithParameters:params];
	        // [labelView setImage:labelImage];
	        [labelView.imageView setImage:labelImage];


	        // TODO: This is probably needed for changing the text dynamically, needed later?
            // CGRect frame = labelView.imageView.frame;
            // frame.size = labelImage.size;

            // [labelView.imageView setFrame:frame];

	        // if([labelView isKindOfClass:%c(SBIconLegibilityLabelView)]) {

	        // }
	        // TODO: is this still needed for Dock icons?
	        // else if ([labelView isKindOfClass:%c(SBIconSimpleLabelView)]) {
	        // 	HBLogWarn(@"Got a simple View");
	        //     // SBIconSimpleLabelView (used for Dock Icons) is already a UIImageView, so no need to get imageView

	        //     CGRect frame = labelView.frame;
	        //     frame.size = labelImage.size;

	        //     [labelView setFrame:frame];
	        // }
	    }

	    %orig;
	}

	-(void)_createAccessoryViewIfNecessary {
		// Disable regular badges
		return;
	}
%end

%subclass CBIconLabelImageParameters : SBIconLabelImageParameters
	%property (nonatomic, retain) SBApplicationIcon *icon;

	%new
	-(id)initWithParameters:(SBIconLabelImageParameters *)params icon:(SBIcon *)icon {
	    self = [self initWithParameters:params];

        if([icon isFolderIcon]) {
        	// TODO
            // self.folderIcon = (SBFolderIcon *)icon;
            // self.icon = [self mainIconForFolder:icon];
        } else {
            self.icon = (SBApplicationIcon *)icon;
        }

	    return self;
	}

	-(BOOL)isColorspaceGrayscale {
		return NO;
	}

	-(UIColor *)focusHighlightColor {
		if ([self.icon badgeValue] > 0) {
			UIColor *avgColor = [[self.icon unmaskedIconImageWithInfo:nil] averageColor];
			return avgColor;
		}

		return %orig;
	}
%end

%ctor {
	HBLogWarn(@"----- CozyBadges loaded -----");
}
