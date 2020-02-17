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

@implementation CozBadLogo

- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Banner" specifier:specifier];
	if (self) {
		CGFloat x = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? -20 : 0;

		UILabel *tweakName = [[UILabel alloc] initWithFrame:CGRectMake(x, 23, self.frame.size.width, 10)];
		[tweakName layoutIfNeeded];
		tweakName.numberOfLines = 1;
		tweakName.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:34.0f];
		tweakName.textColor = [UIColor colorWithRed:0.38 green:0.56 blue:0.76 alpha:1.0];;

		NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"COZYBADGES"];
		[attrString beginEditing];
		[attrString addAttribute:NSFontAttributeName
					value:[UIFont fontWithName:@"HelveticaNeue" size:34.0f]
					range:NSMakeRange(0, 4)];

		[attrString endEditing];
		tweakName.attributedText = attrString;

		tweakName.textAlignment = NSTextAlignmentCenter;
		[self addSubview:tweakName];

		version = [[UILabel alloc] initWithFrame:CGRectMake(x, 55, self.frame.size.width, 5)];
		version.numberOfLines = 1;
		version.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		version.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
		version.textColor = UIColor.systemGrayColor;
		version.textAlignment = NSTextAlignmentCenter;
		version.text = @"Version unknown";
		version.alpha = 0;
		[self addSubview:version];

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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

