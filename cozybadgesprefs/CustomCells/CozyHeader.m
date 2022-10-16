#include "../CozyHeaders.h"

@implementation CozyHeader

- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Banner" specifier:specifier];
	if (self) {
		CGFloat x = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? -20 : 0;

		UILabel *tweakName = [[UILabel alloc] initWithFrame:CGRectMake(x, 23, self.frame.size.width, 10)];
		[tweakName layoutIfNeeded];
		tweakName.numberOfLines = 1;
		tweakName.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:34.0f];
		tweakName.textColor = kCOZYCOLOR;

		NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"COZYBADGES"];
		[attrString beginEditing];
		[attrString addAttribute:NSFontAttributeName
					value:[UIFont fontWithName:@"HelveticaNeue" size:34.0f]
					range:NSMakeRange(0, 4)];

		[attrString endEditing];
		tweakName.attributedText = attrString;

		tweakName.textAlignment = NSTextAlignmentCenter;
		[self addSubview:tweakName];

		UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(x, 55, self.frame.size.width, 5)];
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

				version.alpha = 1;
			});
		});

	}
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return 100.0f;
}
@end