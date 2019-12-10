#import <Preferences/PSTableCell.h>

@interface UIColor (CozyBadges)
@property(class, nonatomic, readonly) UIColor *labelColor;
@property(class, nonatomic, readonly) UIColor *systemGrayColor;
@end

@interface PSControlTableCell : PSTableCell
@property (nonatomic, retain) UIControl *control;
@end

@interface PSSwitchTableCell : PSControlTableCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(id)specifier;
@end

@interface CozBadSwitchTableCell : PSSwitchTableCell
@end

@interface CozBadButtonCell : PSTableCell
@end

@interface CozBadGreyButtonCell : PSTableCell
@end
