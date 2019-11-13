#import <Preferences/PSSpecifier.h>
#import "CozBadCustomCells.h"

@implementation CozBadSwitchTableCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		[((UISwitch *)[self control]) setOnTintColor:[UIColor colorWithRed:0.38 green:0.56 blue:0.76 alpha:1.0]];
	}

	return self;
}

@end

@implementation CozBadButtonCell

-(void) layoutSubviews {
	[super layoutSubviews];
	[[self textLabel] setTextColor:[UIColor colorWithRed:0.38 green:0.56 blue:0.76 alpha:1.0]];
}

@end
