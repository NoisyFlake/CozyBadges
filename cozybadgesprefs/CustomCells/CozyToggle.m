#include "../CozyHeaders.h"

@interface CozyToggle : PSSwitchTableCell
@end

@implementation CozyToggle

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		[((UISwitch *)[self control]) setOnTintColor:kCOZYCOLOR];
	}

	return self;
}

@end