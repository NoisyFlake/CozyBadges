#include "../CozyHeaders.h"

@interface PSSegmentableSlider : UISlider
@end

@interface CozySlider : PSSliderTableCell
@end

@implementation CozySlider

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		[((PSSegmentableSlider *)[self control]) setMinimumTrackTintColor:kCOZYCOLOR];
	}

	return self;
}

@end