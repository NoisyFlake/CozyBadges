#include "../CozyHeaders.h"

@interface CozyButton : PSTableCell
@end

@implementation CozyButton

-(void) layoutSubviews {
	[super layoutSubviews];

    self.textLabel.textColor = [[self.specifier propertyForKey:@"style"] isEqual:@"disabled"] ? UIColor.systemGrayColor : UIColor.labelColor;
    self.textLabel.highlightedTextColor = kCOZYCOLOR;
}

@end